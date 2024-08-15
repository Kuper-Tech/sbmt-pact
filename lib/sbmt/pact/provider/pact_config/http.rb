# frozen_string_literal: true

require_relative "base"

module Sbmt
  module Pact
    module Provider
      module PactConfig
        class Http < Base
          attr_reader :http_port

          def initialize(provider_name:, opts: {})
            super

            @http_port = opts[:http_port] || 3000
          end

          def new_verifier
            HttpVerifier.new(self)
          end
        end
      end
    end
  end
end
