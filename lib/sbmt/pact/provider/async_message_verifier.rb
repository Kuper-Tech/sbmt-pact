# frozen_string_literal: true

require "pact/ffi/verifier"
require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Provider
      class AsyncMessageVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "message"
        INTERACTION_FILTER_REGEX = "^async:.+"

        def initialize(pact_config)
          super

          raise ArgumentError, "pact_config must be an instance of Sbmt::Pact::Provider::PactConfig::Message" unless pact_config.is_a?(::Sbmt::Pact::Provider::PactConfig::Async)
        end

        private

        def add_provider_transport(pact_handle)
          setup_uri = URI(@pact_config.message_setup_url)
          PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, setup_uri.port, setup_uri.path, "")
        end

        def set_filter_info(pact_handle)
          PactFfi::Verifier.set_filter_info(pact_handle, INTERACTION_FILTER_REGEX, nil, 0)
        end
      end
    end
  end
end
