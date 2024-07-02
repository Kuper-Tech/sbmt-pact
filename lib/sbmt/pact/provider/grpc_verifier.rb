# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class GrpcVerifier
        attr_reader :logger

        class VerificationError < Sbmt::Pact::FfiError; end

        class VerifierError < Sbmt::Pact::Error; end

        PROVIDER_TRANSPORT_TYPE = "grpc"

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
          raise ArgumentError, "pact_config must be an instance of Sbmt::Pact::Provider::PactConfig::Grpc" unless pact_config.is_a?(::Sbmt::Pact::Provider::PactConfig::Grpc)
          @pact_config = pact_config

          @provider_state = nil
          @grpc_server = GrufServer.new(hostname: "127.0.0.1:#{@pact_config.grpc_port}", services: @pact_config.grpc_services)
          @logger = Logger.new($stdout)
        end

        def verify!
          raise VerifierError.new("interaction is designed to be used one-time only") if defined?(@used)

          exception = nil
          pact_handle = init_pact

          start_servers!

          logger.info("[grpc_verifier] starting provider verification")

          result = PactFfi::Verifier.execute(pact_handle)
          if VERIFICATION_ERRORS[result].present?
            error = VERIFICATION_ERRORS[result]
            exception = VerificationError.new("There was an error while trying to verify provider \"#{@pact_config.provider_name}\"", error[:reason], error[:status])
          end
        ensure
          @used = true
          PactFfi::Verifier.shutdown(pact_handle)
          stop_servers

          raise exception if exception
        end

        private

        def init_pact
          handle = PactFfi::Verifier.new_for_application("sbmt-pact", PactFfi.version)
          PactFfi::Verifier.set_provider_info(handle, @pact_config.provider_name, "", "", 0, "")
          PactFfi::Verifier.set_provider_state(handle, @pact_config.provider_setup_url, 1, 1)
          PactFfi::Verifier.set_verification_options(handle, 0, 10000)
          PactFfi::Verifier.set_publish_options(handle, @pact_config.provider_version, "", nil, 0, "")

          configure_verification_source(handle)

          PactFfi::Verifier.set_no_pacts_is_error(handle, 1)
          PactFfi::Verifier.add_provider_transport(handle, PROVIDER_TRANSPORT_TYPE, @pact_config.grpc_port, "", "")
          PactFfi::Verifier.set_filter_info(handle, nil, @provider_state, 0) if @provider_state

          Sbmt::Pact::Native::Logger.log_to_stdout(@pact_config.log_level)

          logger.info("[grpc_verifier] verification initialized for provider #{@pact_config.provider_name}, version #{@pact_config.provider_version}")

          handle
        end

        def start_servers!
          logger.info("[grpc_verifier] starting services")

          @grpc_server.start
          @pact_config.provider_setup_server.start
        end

        def stop_servers
          logger.info("[grpc_verifier] stopping services")

          @grpc_server.stop
          @pact_config.provider_setup_server.stop
        end

        def configure_verification_source(handle)
          if @pact_config.broker_url.blank?
            path = Rails.root.join("pacts").to_s
            logger.info("[grpc_verifier] pact broker url is not set, using #{path} as a verification source")
            return PactFfi::Verifier.add_directory_source(handle, path)
          end

          selectors = build_consumer_selectors(@pact_config.verify_only, @pact_config.consumer_name, @pact_config.consumer_branch)
          if selectors.blank?
            logger.info("[grpc_verifier] no consumer selectors, using pact broker url #{@pact_config.broker_url} as a verification source")
            return PactFfi::Verifier.broker_source(handle, @pact_config.broker_url, @pact_config.broker_username, @pact_config.broker_password, nil)
          end

          logger.info("[grpc_verifier] using pact broker url #{@pact_config.broker_url} with consumer selectors: #{JSON.dump(selectors)} as a verification source")

          filters = selectors.map do |selector|
            FFI::MemoryPointer.from_string(JSON.dump(selector).to_s)
          end
          filters_ptr = FFI::MemoryPointer.new(:pointer, filters.size + 1)
          filters_ptr.write_array_of_pointer(filters)
          PactFfi::Verifier.broker_source_with_selectors(handle, @pact_config.broker_url, @pact_config.broker_username, @pact_config.broker_password, nil, 0, nil, nil, 0, nil, filters_ptr, filters.size, nil, 0)
        end

        def build_consumer_selectors(verify_only, consumer_name, consumer_branch)
          # if verify_only and consumer_name are defined - select only needed consumer
          if verify_only.present?
            # select proper consumer branch if defined
            if consumer_name.present? && verify_only.include?(consumer_name)
              return [{"branch" => consumer_branch.presence || "master", "consumer" => consumer_name}]
            end
            # or main branches otherwise
            return verify_only.map { |name| {"consumer" => name, "branch" => "master"} }
          end

          # select provided consumer_name
          return [{"branch" => consumer_branch.presence || "master", "consumer" => consumer_name}] if consumer_name.present?

          [{"branch" => "master"}]
        end
      end
    end
  end
end
