# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"
require "sbmt/pact/native/blocking_verifier"

module Sbmt
  module Pact
    module Provider
      class BaseVerifier
        PROVIDER_TRANSPORT_TYPE = nil
        attr_reader :logger

        class VerificationError < Sbmt::Pact::FfiError; end

        class VerifierError < Sbmt::Pact::Error; end

        DEFAULT_CONSUMER_SELECTORS = {"deployed" => true, "environment" => "production"}.freeze

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/verifier/fn.pactffi_verify.html#errors
        VERIFICATION_ERRORS = {
          1 => {reason: :verification_failed, status: 1, description: "The verification process failed, see output for errors"},
          2 => {reason: :null_pointer, status: 2, description: "A null pointer was received"},
          3 => {reason: :internal_error, status: 3, description: "The method panicked"},
          4 => {reason: :invalid_arguments, status: 4, description: "Invalid arguments were provided to the verification process"}
        }.freeze

        # env below are set up by pipeline-builder
        # see https://gitlab.sbmt.io/paas/cicd/images/pact/pipeline-builder/-/blob/master/internal/commands/consumers-pipeline/ruby.go
        def initialize(pact_config)
          raise ArgumentError, "pact_config must be a subclass of Sbmt::Pact::Provider::PactConfig::Base" unless pact_config.is_a?(::Sbmt::Pact::Provider::PactConfig::Base)
          @pact_config = pact_config
          @logger = Logger.new($stdout)
        end

        def verify!
          raise VerifierError.new("interaction is designed to be used one-time only") if defined?(@used)

          if consumer_selectors.blank?
            logger.info("[verifier] does not need to verify consumer #{@pact_config.consumer_name}")
            return
          end

          exception = nil
          pact_handle = init_pact

          start_servers!

          logger.info("[verifier] starting provider verification")

          result = Sbmt::Pact::Native::BlockingVerifier.execute(pact_handle)
          if VERIFICATION_ERRORS[result].present?
            error = VERIFICATION_ERRORS[result]
            exception = VerificationError.new("There was an error while trying to verify provider \"#{@pact_config.provider_name}\"", error[:reason], error[:status])
          end
        ensure
          @used = true
          PactFfi::Verifier.shutdown(pact_handle) if pact_handle
          stop_servers

          raise exception if exception
        end

        private

        def init_pact
          handle = PactFfi::Verifier.new_for_application("sbmt-pact", PactFfi.version)
          set_provider_info(handle)
          PactFfi::Verifier.set_provider_state(handle, @pact_config.provider_setup_url, 1, 1)
          PactFfi::Verifier.set_verification_options(handle, 0, 10000)
          PactFfi::Verifier.set_publish_options(handle, @pact_config.provider_version, "", nil, 0, "")

          configure_verification_source(handle)

          PactFfi::Verifier.set_no_pacts_is_error(handle, 1)

          add_provider_transport(handle)
          set_filter_info(handle)

          Sbmt::Pact::Native::Logger.log_to_stdout(@pact_config.log_level)

          logger.info("[verifier] verification initialized for provider #{@pact_config.provider_name}, version #{@pact_config.provider_version}, transport #{self.class::PROVIDER_TRANSPORT_TYPE}")

          handle
        end

        def set_provider_info(pact_handle)
          PactFfi::Verifier.set_provider_info(pact_handle, @pact_config.provider_name, "", "", 0, "")
        end

        def add_provider_transport(pact_handle)
          raise Sbmt::Pact::ImplementationRequired, "Implement #add_provider_transport in a subclass"
        end

        def set_filter_info(pact_handle)
          # e.g. PactFfi::Verifier.set_filter_info(pact_handle, "^grpc:.+", nil, 0)
          raise Sbmt::Pact::ImplementationRequired, "Implement #set_filter_info in a subclass"
        end

        def start_servers!
          logger.info("[verifier] starting services")

          @servers_started = true
          @pact_config.start_servers
        end

        def stop_servers
          return unless @servers_started

          logger.info("[verifier] stopping services")

          @pact_config.stop_servers
        end

        def configure_verification_source(handle)
          if @pact_config.pact_broker_proxy_url.blank?
            path = Rails.root.join("pacts").to_s
            logger.info("[verifier] pact broker url is not set, using #{path} as a verification source")
            return PactFfi::Verifier.add_directory_source(handle, path)
          end

          logger.info("[verifier] using pact broker url #{@pact_config.broker_url} with consumer selectors: #{JSON.dump(consumer_selectors)} as a verification source")

          filters = consumer_selectors.map do |selector|
            FFI::MemoryPointer.from_string(JSON.dump(selector).to_s)
          end
          filters_ptr = FFI::MemoryPointer.new(:pointer, filters.size + 1)
          filters_ptr.write_array_of_pointer(filters)
          PactFfi::Verifier.broker_source_with_selectors(handle, @pact_config.pact_broker_proxy_url, @pact_config.broker_username, @pact_config.broker_password, nil, 0, nil, nil, 0, nil, filters_ptr, filters.size, nil, 0)
        end

        def consumer_selectors
          @consumer_selectors ||= build_consumer_selectors(@pact_config.verify_only, @pact_config.consumer_name, @pact_config.consumer_branch)
        end

        def build_consumer_selectors(verify_only, consumer_name, consumer_branch)
          # if verify_only and consumer_name are defined - select only needed consumer
          if verify_only.present?
            # select proper consumer branch if defined
            if consumer_name.present?
              return [] unless verify_only.include?(consumer_name)
              return [{"branch" => consumer_branch, "consumer" => consumer_name}] if consumer_branch.present?
              return [DEFAULT_CONSUMER_SELECTORS.merge("consumer" => consumer_name)]
            end
            # or default selectors
            return verify_only.map { |name| DEFAULT_CONSUMER_SELECTORS.merge("consumer" => name) }
          end

          # select provided consumer_name
          return [{"branch" => consumer_branch, "consumer" => consumer_name}] if consumer_name.present? && consumer_branch.present?
          return [DEFAULT_CONSUMER_SELECTORS.merge("consumer" => consumer_name)] if consumer_name.present?

          [DEFAULT_CONSUMER_SELECTORS]
        end
      end
    end
  end
end
