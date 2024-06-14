# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class GrpcVerifier
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
        end

        def verify!
          raise VerifierError.new("interaction is designed to be used one-time only") if defined?(@used)

          pact_handle = init_pact

          start_servers!

          result = PactFfi::Verifier.execute(pact_handle)
          if VERIFICATION_ERRORS[result].present?
            error = VERIFICATION_ERRORS[result]
            raise VerificationError.new("There was an error while trying to verify provider \"#{@pact_config.provider_name}\"", error[:reason], error[:status])
          end
        ensure
          @used = true
          stop_servers
          PactFfi::Verifier.shutdown(pact_handle)
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

          handle
        end

        def start_servers!
          @grpc_server.start
          @pact_config.provider_setup_server.start
        end

        def stop_servers
          @grpc_server.stop
          @pact_config.provider_setup_server.stop
        end

        def configure_verification_source(handle)
          return PactFfi::Verifier.add_directory_source(handle, Rails.root.join("pacts").to_s) if @pact_config.broker_url.blank?
          return PactFfi::Verifier.broker_source(handle, @pact_config.broker_url, @pact_config.broker_username, @pact_config.broker_password, nil) if @pact_config.consumer_branch.blank?

          json = JSON.dump(branch: @pact_config.consumer_branch).to_s
          filters = [FFI::MemoryPointer.from_string(json)]
          filters_ptr = FFI::MemoryPointer.new(:pointer, filters.size + 1)
          filters_ptr.write_array_of_pointer(filters)
          PactFfi::Verifier.broker_source_with_selectors(handle, @pact_config.broker_url, @pact_config.broker_username, @pact_config.broker_password, nil, 0, nil, nil, 0, nil, filters_ptr, filters.size, nil, 0)
        end
      end
    end
  end
end
