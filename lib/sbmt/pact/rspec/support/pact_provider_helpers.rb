# frozen_string_literal: true

module SbmtPactProducerDsl
  module ClassMethods
    def grpc_pact_provider(provider, opts: {})
      raise "grpc_pact_provider is designed to be used with RSpec" unless defined?(::RSpec)
      raise "grpc_pact_provider has to be declared at the top level of a suite" unless top_level?
      raise "grpc_pact_provider is designed to be run once per provider so cannot be declared more than once" if defined?(@_pact_config)

      pact_config_instance = Sbmt::Pact::Provider::PactConfig.new_grpc(provider_name: provider, opts: opts)
      instance_variable_set(:@_pact_config, pact_config_instance)

      # rubocop:disable RSpec/BeforeAfterAll
      before(:context) do
        # rspec allows only context ivars in specs and ignores the rest
        # so we use block-as-a-closure feature to save pact_config ivar reference and make it available for descendants
        @_pact_config = pact_config_instance
      end
      # rubocop:enable RSpec/BeforeAfterAll

      it "verifies interactions with provider #{provider}" do
        pact_config.new_verifier.verify!
      end
    end

    def before_state_setup(&block)
      raise "grpc_pact_provider should be declared first" unless pact_config
      pact_config.before_setup(&block)
    end

    def after_state_teardown(&block)
      raise "grpc_pact_provider should be declared first" unless pact_config
      pact_config.after_teardown(&block)
    end

    def provider_state(name, opts: {}, &block)
      raise "grpc_pact_provider should be declared first" unless pact_config
      pact_config.new_provider_state(name, opts: opts, &block)
    end

    def pact_config
      instance_variable_get(:@_pact_config)
    end
  end

  def pact_config
    instance_variable_get(:@_pact_config)
  end
end

RSpec.configure do |config|
  config.include SbmtPactProducerDsl, pact_entity: :provider
  config.extend SbmtPactProducerDsl::ClassMethods, pact_entity: :provider
end
