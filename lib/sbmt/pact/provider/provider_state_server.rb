# frozen_string_literal: true

require "webrick"

module Sbmt
  module Pact
    module Provider
      class ProviderStateServer < WEBrick::HTTPServer
        attr_reader :logger

        def initialize(port: 9001, host: "127.0.0.1", path: nil, logger: nil)
          super({BindAddress: host, Port: port}, WEBrick::Config::HTTP)

          @path = path || "/setup-provider"
          @provider_setup_states = {}
          @provider_teardown_states = {}
          @logger = logger || Logger.new($stdout)

          mount_proc(@path) do |request, response|
            # {"action" => "setup", "params" => {"order_uuid" => "mxfcpcsfUOHO"},"state" => "order exists and can be saved"}
            # {"action"=> "teardown", "params" => {"order_uuid" => "mxfcpcsfUOHO"}, "state" => "order exists and can be saved"}
            data = JSON.parse(request.body)

            action = data["action"]
            state_name = data["state"]
            state_data = data["params"]

            logger.warn("unknown callback state action: #{action}") if action.blank?

            call_setup(state_name, state_data) if action == "setup"
            call_teardown(state_name, state_data) if action == "teardown"

            response.status = 200
          rescue JSON::ParserError => ex
            logger.error("cannot parse request: #{ex.message}")
            response.status = 500
          end
        end

        def add_setup_state(name, &block)
          raise "provider state #{name} already configured" if @provider_setup_states[name].present?

          @provider_setup_states[name] = block
        end

        def add_teardown_state(name, &block)
          raise "provider state #{name} already configured" if @provider_teardown_states[name].present?

          @provider_teardown_states[name] = block
        end

        private

        def call_setup(state_name, state_data)
          return if @provider_setup_states[state_name].blank?

          @provider_setup_states[state_name].call(state_data)
        end

        def call_teardown(state_name, state_data)
          return if @provider_teardown_states[state_name].blank?

          @provider_teardown_states[state_name].call(state_data)
        end
      end
    end
  end
end
