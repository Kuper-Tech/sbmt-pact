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

        # env below are set up by pipeline-builder
        # see https://gitlab.sbmt.io/paas/cicd/images/pact/pipeline-builder/-/blob/master/internal/commands/consumers-pipeline/ruby.go
        def initialize(
          provider_name:, grpc_server_port: 3009, provider_setup_port: 9001, log_level: :info,
          provider_version: ENV.fetch("PACT_PROVIDER_VERSION", "1.0.0"),
          consumer_branch: ENV.fetch("PACT_CONSUMER_BRANCH", nil),
          consumer_version: ENV.fetch("PACT_CONSUMER_VERSION", "1.0.0"),
          broker_url: ENV.fetch("PACT_BROKER_URL", nil),
          broker_username: ENV.fetch("PACT_BROKER_USERNAME", ""),
          broker_password: ENV.fetch("PACT_BROKER_PASSWORD", "")
        )
          @provider_name = provider_name
          @grpc_server_port = grpc_server_port
          @provider_setup_port = provider_setup_port
          @provider_version = provider_version
          @consumer_branch = consumer_branch
          @consumer_version = consumer_version
          @broker_url = broker_url
          @broker_username = broker_username
          @broker_password = broker_password

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
          PactFfi::Verifier.set_verification_options(handle, 0, 10000)
          PactFfi::Verifier.set_publish_options(handle, @provider_version, "", nil, 0, "")

          configure_verification_source(handle, @consumer_branch)

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

        def configure_verification_source(handle, consumer_branch)
          return PactFfi::Verifier.add_directory_source(handle, Rails.root.join("pacts").to_s) if @broker_url.blank?
          return PactFfi::Verifier.broker_source(handle, @broker_url, @broker_username, @broker_password, nil) if consumer_branch.blank?

          json = JSON.dump(branch: consumer_branch).to_s
          filters = [FFI::MemoryPointer.from_string(json)]
          filters_ptr = FFI::MemoryPointer.new(:pointer, filters.size + 1)
          filters_ptr.write_array_of_pointer(filters)
          PactFfi::Verifier.broker_source_with_selectors(handle, @broker_url, @broker_username, @broker_password, nil, 0, nil, nil, 0, nil, filters_ptr, filters.size, nil, 0)
        end
      end
    end
  end
end
