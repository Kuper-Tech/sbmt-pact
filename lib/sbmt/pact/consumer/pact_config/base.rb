# frozen_string_literal: true

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        class Base
          attr_reader :consumer_name, :provider_name, :pact_dir, :log_level

          def initialize(consumer_name:, provider_name:, pact_dir: nil, log_level: :info)
            @consumer_name = consumer_name
            @provider_name = provider_name
            @pact_dir = pact_dir || Rails.root.join("pacts").to_s
            @log_level = log_level
          end
        end
      end
    end
  end
end
