# frozen_string_literal: true

module Sbmt
  module Pact
    module Provider
      module PactConfig
        class Base
          attr_reader :provider_name, :provider_version, :log_level, :provider_setup_server, :provider_setup_port, :pact_proxy_port,
            :consumer_branch, :consumer_version, :consumer_name, :broker_url, :broker_username, :broker_password, :verify_only

          PACT_BROKER_FILTER_TYPE_NONE = PactBrokerProxyRunner::FILTER_TYPE_NONE
          PACT_BROKER_FILTER_TYPE_GRPC = PactBrokerProxyRunner::FILTER_TYPE_GRPC
          PACT_BROKER_FILTER_TYPE_ASYNC = PactBrokerProxyRunner::FILTER_TYPE_ASYNC
          PACT_BROKER_FILTER_TYPE_SYNC = PactBrokerProxyRunner::FILTER_TYPE_SYNC
          PACT_BROKER_FILTER_TYPE_HTTP = PactBrokerProxyRunner::FILTER_TYPE_HTTP

          def initialize(provider_name:, opts: {})
            @provider_name = provider_name
            @log_level = opts[:log_level] || :info
            @provider_setup_port = opts[:provider_setup_port] || 9001
            @pact_proxy_port = opts[:provider_setup_port] || 9002
            @provider_version = opts[:provider_version] || ENV.fetch("PACT_PROVIDER_VERSION", "1.0.0")
            @consumer_branch = opts[:consumer_branch] || ENV.fetch("PACT_CONSUMER_BRANCH", nil)
            @consumer_version = opts[:consumer_version] || ENV.fetch("PACT_CONSUMER_VERSION", nil)
            @consumer_name = opts[:consumer_name]
            @broker_url = opts[:broker_url] || ENV.fetch("PACT_BROKER_URL", nil)
            @broker_username = opts[:broker_username] || ENV.fetch("PACT_BROKER_USERNAME", "")
            @broker_password = opts[:broker_password] || ENV.fetch("PACT_BROKER_PASSWORD", "")
            @verify_only = opts[:verify_only] || [ENV.fetch("PACT_CONSUMER_FULL_NAME", nil)].compact

            @provider_setup_server = ProviderServerRunner.new(port: @provider_setup_port)
            if @broker_url.present?
              @pact_proxy_server = PactBrokerProxyRunner.new(
                port: @pact_proxy_port, pact_broker_host: @broker_url, filter_type: filter_type,
                pact_broker_user: @broker_username, pact_broker_password: @broker_password
              )
            end
          end

          def filter_type
            PACT_BROKER_FILTER_TYPE_NONE
          end

          def start_servers
            @provider_setup_server.start
            @pact_proxy_server&.start
          end

          def stop_servers
            @provider_setup_server.stop
            @pact_proxy_server&.stop
          end

          def provider_setup_url
            @provider_setup_server.state_setup_url
          end

          def message_setup_url
            @provider_setup_server.message_setup_url
          end

          def pact_broker_proxy_url
            @pact_proxy_server&.proxy_url
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
            raise Sbmt::Pact::ImplementationRequired, "#new_verifier should be implemented"
          end
        end
      end
    end
  end
end
