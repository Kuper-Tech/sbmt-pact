# frozen_string_literal: true

module Dsl
  module ClassMethods
    def has_grpc_pact_between(consumer, provider, opts: {})
      raise "has_pact_between is designed to be used with RSpec 3+" unless defined?(::RSpec)
      raise "has_pact_between has to be declared at the top level of a suite" unless top_level?
      raise "has_pact_between cannot be declared more than once per suite" if defined?(@_pact_config)

      # rubocop:disable RSpec/BeforeAfterAll
      before(:context) do
        @_pact_config = Sbmt::Pact::Consumer::PactConfig.new_grpc(consumer_name: consumer, provider_name: provider, **opts)
      end
      # rubocop:enable RSpec/BeforeAfterAll
    end
  end

  def new_interaction(description = nil)
    pact_config.new_interaction(description)
  end

  def pact_config
    instance_variable_get(:@_pact_config)
  end
end

RSpec.configure do |config|
  config.include Dsl, pact_entity: :consumer
  config.extend Dsl::ClassMethods, pact_entity: :consumer
end
