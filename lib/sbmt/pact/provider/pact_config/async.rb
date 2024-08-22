# frozen_string_literal: true

require_relative "base"

module Sbmt
  module Pact
    module Provider
      module PactConfig
        class Async < Base
          def new_message_handler(name, opts: {}, &block)
            provider_setup_server.add_message_handler(name, &block)
          end

          def filter_type
            PACT_BROKER_FILTER_TYPE_ASYNC
          end

          def new_verifier
            AsyncMessageVerifier.new(self)
          end
        end
      end
    end
  end
end
