# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class HttpVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "http"

        def initialize(pact_config)
          super

          raise ArgumentError, "pact_config must be an instance of Sbmt::Pact::Provider::PactConfig::Http" unless pact_config.is_a?(::Sbmt::Pact::Provider::PactConfig::Http)
          @http_server = HttpServer.new(host: "127.0.0.1", port: @pact_config.http_port)
        end

        private

        def set_provider_info(pact_handle)
          PactFfi::Verifier.set_provider_info(pact_handle, @pact_config.provider_name, "", "", @pact_config.http_port, "")
        end

        def add_provider_transport(pact_handle)
          # The http transport is already added when the `set_provider_info` method is called,
          # so we don't need to explicitly add the transport here
        end

        def set_filter_info(pact_handle)
          PactFfi::Verifier.set_filter_info(pact_handle, "^http:.+", nil, 0)
        end

        def start_servers!
          super
          @http_server.start
        end

        def stop_servers
          super
          @http_server.stop
        end
      end
    end
  end
end
