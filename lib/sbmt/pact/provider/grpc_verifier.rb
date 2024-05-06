# frozen_string_literal: true

require "pact/ffi/verifier"

require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class GrpcVerifier
        class VerificationError < Sbmt::Pact::FfiError; end

        PROVIDER_TRANSPORT_TYPE = "grpc"

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/verifier/fn.pactffi_verify.html#errors
        VERIFICATION_ERRORS = {
          1 => {reason: :verification_failed, status: 1, description: "The verification process failed, see output for errors"},
          2 => {reason: :null_pointer, status: 2, description: "A null pointer was received"},
          3 => {reason: :internal_error, status: 3, description: "The method panicked"},
          4 => {reason: :invalid_arguments, status: 4, description: "Invalid arguments were provided to the verification process"}
        }.freeze

        def initialize(provider_name:, grpc_server_port: 3009, provider_setup_port: 9001, log_level: :info)
          @provider_name = provider_name
          @grpc_server_port = grpc_server_port
          @provider_setup_port = provider_setup_port

          @provider_state = nil

          @pact = init_pact(log_level: log_level)
          @grpc_server = GrufServer.new(hostname: "127.0.0.1:#{grpc_server_port}")
          @provider_setup_server = ProviderServerRunner.new(port: provider_setup_port)
        end

        def with_provider_state(provider_state)
          @provider_state = provider_state
          self
        end

        def set_up(state_name, &block)
          @provider_setup_server.add_setup_state(state_name, &block)
          self
        end

        def tear_down(state_name, &block)
          @provider_setup_server.add_teardown_state(state_name, &block)
          self
        end

        def verify!
          start_servers

          result = PactFfi::Verifier.execute(@pact)
          if VERIFICATION_ERRORS[result].present?
            error = VERIFICATION_ERRORS[result]
            raise VerificationError.new("There was an error while trying to verify provider \"#{@provider_name}\"", error[:reason], error[:status])
          end
        end

        def cleanup
          @grpc_server.stop
          @provider_setup_server.stop
          PactFfi::Verifier.shutdown(@pact)
        end

        private

        def init_pact(log_level:)
          handle = PactFfi::Verifier.new_for_application("sbmt-pact", PactFfi.version)
          PactFfi::Verifier.set_provider_info(handle, @provider_name, "", "", 0, "")
          PactFfi::Verifier.set_provider_state(handle, provider_setup_url, 1, 1)
          PactFfi::Verifier.set_verification_options(handle, 0, 1000)
          PactFfi::Verifier.set_publish_options(handle, "1.0.0", "", nil, 0, "")

          # TODO: use pact-broker instead of directory source
          # PactFfi::Verifier.broker_source(pact, PACT_BROKER_URL, PACT_BROKER_USERNAME, PACT_BROKER_PASSWORD, PACT_BROKER_TOKEN)
          PactFfi::Verifier.add_directory_source(handle, Rails.root.join("pacts").to_s)

          PactFfi::Verifier.set_no_pacts_is_error(handle, 1)
          PactFfi::Verifier.add_provider_transport(handle, PROVIDER_TRANSPORT_TYPE, @grpc_server_port, "", "")
          PactFfi::Verifier.set_filter_info(handle, nil, @provider_state, 0) if @provider_state

          Sbmt::Pact::Native::Logger.log_to_stdout(log_level)

          handle
        end

        def provider_setup_url
          "http://localhost:#{@provider_setup_port}/setup-provider"
        end

        def start_servers
          @grpc_server.start
          @provider_setup_server.start
        end
      end
    end
  end
end
