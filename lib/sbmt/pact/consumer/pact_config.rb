# frozen_string_literal: true

require_relative "pact_config/grpc"

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        def self.new_grpc(consumer_name:, provider_name:, mock_host: "127.0.0.1", mock_port: 3009, log_level: :info)
          Grpc.new(
            consumer_name: consumer_name, provider_name: provider_name,
            mock_host: mock_host, mock_port: mock_port,
            log_level: log_level
          )
        end
      end
    end
  end
end
