# frozen_string_literal: true

module Sbmt
  module Pact
    module Consumer
      module PactConfig
        class Base
          attr_reader :consumer_name, :provider_name, :pact_dir, :log_level

          def initialize(consumer_name:, provider_name:, opts: {})
            @consumer_name = consumer_name
            @provider_name = provider_name
            @pact_dir = opts[:pact_dir] || Rails.root.join("pacts").to_s
            @log_level = opts[:log_level] || :info
          end

          def new_interaction(description = nil)
            raise Sbmt::Pact::ImplementationRequired, "#new_interaction should be implemented"
          end
        end
      end
    end
  end
end
