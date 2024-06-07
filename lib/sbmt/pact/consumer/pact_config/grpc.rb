# frozen_string_literal: true

require_relative "base"

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        class Grpc < Base
          attr_reader :mock_host, :mock_port

          def initialize(consumer_name:, provider_name:, mock_host: "127.0.0.1", mock_port: 3009, pact_dir: nil, log_level: :info)
            super(consumer_name: consumer_name, provider_name: provider_name, pact_dir: pact_dir, log_level: log_level)

            @mock_host = mock_host
            @mock_port = mock_port
          end

          def new_interaction(description = nil)
            GrpcInteractionBuilder.new(self, description: description)
          end
        end
      end
    end
  end
end
