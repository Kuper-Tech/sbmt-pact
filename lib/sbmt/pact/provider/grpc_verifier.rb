# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class GrpcVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "grpc"
        INTERACTION_FILTER_REGEX = "^grpc:.+"

        def initialize(pact_config)
          super

          raise ArgumentError, "pact_config must be an instance of Sbmt::Pact::Provider::PactConfig::Grpc" unless pact_config.is_a?(::Sbmt::Pact::Provider::PactConfig::Grpc)
          @grpc_server = GrufServer.new(hostname: "127.0.0.1:#{@pact_config.grpc_port}", services: @pact_config.grpc_services)
        end

        private

        def add_provider_transport(pact_handle)
          PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, @pact_config.grpc_port, "", "")
        end

        def set_filter_info(pact_handle)
          PactFfi::Verifier.set_filter_info(pact_handle, INTERACTION_FILTER_REGEX, nil, 0)
        end

        def start_servers!
          super
          @grpc_server.start
        end

        def stop_servers
          super
          @grpc_server.stop
        end
      end
    end
  end
end
