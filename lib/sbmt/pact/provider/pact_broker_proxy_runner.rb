# frozen_string_literal: true

require "webrick"

module Sbmt
  module Pact
    module Provider
      class PactBrokerProxyRunner
        attr_reader :logger

        FILTER_TYPE_NONE = nil
        FILTER_TYPE_GRPC = :grpc
        FILTER_TYPE_ASYNC = :async
        FILTER_TYPE_SYNC = :sync
        FILTER_TYPE_HTTP = :http

        def initialize(pact_broker_host:, filter_type: nil, port: 9002, host: "127.0.0.1", pact_broker_user: nil, pact_broker_password: nil, logger: nil)
          @host = host
          @port = port
          @pact_broker_host = pact_broker_host
          @filter_type = filter_type
          @pact_broker_user = pact_broker_user
          @pact_broker_password = pact_broker_password
          @logger = logger || Logger.new($stdout)

          @thread = nil
        end

        def proxy_url
          "http://#{@host}:#{@port}"
        end

        def start
          raise "server already running, stop server before starting new one" if @thread

          @server = WEBrick::HTTPServer.new({BindAddress: @host, Port: @port}, WEBrick::Config::HTTP)
          @server.mount("/", Rack::Handler::WEBrick, PactBrokerProxy.new(
            nil,
            backend: @pact_broker_host, streaming: false, filter_type: @filter_type,
            username: @pact_broker_user, password: @pact_broker_password, logger: @logger
          ))

          @thread = Thread.new do
            Rails.logger.debug "starting pact broker proxy server"
            @server.start
          end
        end

        def stop
          @logger.info("stopping pact broker proxy server")

          @server&.shutdown
          @thread&.join

          @logger.info("pact broker proxy server stopped")
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
      end
    end
  end
end
