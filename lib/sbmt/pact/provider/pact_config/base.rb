# frozen_string_literal: true

module Sbmt
  module Pact
    module Provider
      module PactConfig
        class Base
          attr_reader :provider_name, :provider_version, :log_level, :provider_setup_server, :provider_setup_url, :provider_setup_port,
            :consumer_branch, :consumer_version, :broker_url, :broker_username, :broker_password

          def initialize(provider_name:, opts: {})
            @provider_name = provider_name
            @log_level = opts[:log_level] || :info
            @provider_setup_port = opts[:provider_setup_port] || 9001
            @provider_version = opts[:provider_version] || ENV.fetch("PACT_PROVIDER_VERSION", "1.0.0")
            @consumer_branch = opts[:consumer_branch] || ENV.fetch("PACT_CONSUMER_BRANCH", nil)
            @consumer_version = opts[:consumer_version] || ENV.fetch("PACT_CONSUMER_VERSION", "1.0.0")
            @broker_url = opts[:broker_url] || ENV.fetch("PACT_BROKER_URL", nil)
            @broker_username = opts[:broker_username] || ENV.fetch("PACT_BROKER_USERNAME", "")
            @broker_password = opts[:broker_password] || ENV.fetch("PACT_BROKER_PASSWORD", "")

            @provider_setup_url = opts[:provider_setup_url] || "http://localhost:#{@provider_setup_port}/setup-provider"
            @provider_setup_server = ProviderServerRunner.new(port: @provider_setup_port)
          end

          def new_provider_state(name, opts: {}, &block)
            config = ProviderStateConfiguration.new(name, opts: opts)
            config.instance_eval(&block)
            config.validate!

            use_hooks = !opts[:skip_hooks]

            @provider_setup_server.add_setup_state(name, use_hooks, &config.setup_proc) if config.setup_proc
            @provider_setup_server.add_teardown_state(name, use_hooks, &config.teardown_proc) if config.teardown_proc
          end

          def before_setup(&block)
            @provider_setup_server.set_before_setup_hook(&block)
          end

          def after_teardown(&block)
            @provider_setup_server.set_after_teardown_hook(&block)
          end

          def new_verifier
            raise NotImplementedError, "#new_verifier should be implemented"
          end
        end
      end
    end
  end
end
