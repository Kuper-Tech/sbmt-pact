# frozen_string_literal: true

require_relative "pact_config/grpc"

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        def self.new_grpc(consumer_name:, provider_name:, opts: {})
          Grpc.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        end
      end
    end
  end
end
