# frozen_string_literal: true

require_relative "base"

module Sbmt
  module Pact
    module Provider
      module PactConfig
        class Grpc < Base
          attr_reader :grpc_port, :grpc_services, :grpc_server

          def initialize(provider_name:, opts: {})
            super

            @grpc_port = opts[:grpc_port] || 3009
            @grpc_services = opts[:grpc_services] || []
          end

          def new_verifier
            GrpcVerifier.new(self)
          end
        end
      end
    end
  end
end
