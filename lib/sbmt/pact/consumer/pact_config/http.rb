# frozen_string_literal: true

require_relative "base"

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        class Http < Base
          attr_reader :mock_host, :mock_port

          def initialize(consumer_name:, provider_name:, opts: {})
            super

            @mock_host = opts[:mock_host] || "127.0.0.1"
            @mock_port = opts[:mock_port] || 3000
          end

          def new_interaction(description = nil)
            HttpInteractionBuilder.new(self, description: description)
          end
        end
      end
    end
  end
end
