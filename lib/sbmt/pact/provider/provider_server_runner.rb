# frozen_string_literal: true

require "webrick"

module Sbmt
  module Pact
    module Provider
      class ProviderServerRunner
        attr_reader :logger

        def initialize(port: 9001, host: "127.0.0.1", path: "/setup-provider", logger: nil)
          @path = path
          @provider_setup_states = {}
          @provider_teardown_states = {}
          @logger = logger || Logger.new($stdout)

          @server = ProviderStateServer.new(port: port, host: host, path: path, logger: @logger)
          @thread = nil
        end

        def start
          raise "server already running, stop server before starting new one" if @thread

          @thread = Thread.new do
            Rails.logger.debug "starting provider setup server"
            @server.start
          end
        end

        def stop
          @logger.info("stopping provider setup server")

          @server.stop
          @thread&.join

          @logger.info("provider setup server stopped")
        end

        def run
          start

          yield
        rescue => e
          logger.fatal("FATAL ERROR: #{e.message} #{e.backtrace.join("\n")}")
          raise
        ensure
          stop
        end

        def add_setup_state(state_name, &block)
          @server.add_setup_state(state_name, &block)
        end

        def add_teardown_state(state_name, &block)
          @server.add_teardown_state(state_name, &block)
        end
      end
    end
  end
end
