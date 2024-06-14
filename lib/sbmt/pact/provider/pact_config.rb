# frozen_string_literal: true

require_relative "pact_config/grpc"

module Sbmt
  module Pact
    module Provider
      module PactConfig
        def self.new_grpc(provider_name:, opts: {})
          Grpc.new(provider_name: provider_name, opts: opts)
        end
      end
    end
  end
end
