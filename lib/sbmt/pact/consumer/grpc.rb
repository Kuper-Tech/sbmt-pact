# frozen_string_literal: true

require "pact/ffi/sync_message_consumer"
require "pact/ffi/plugin_consumer"

require "sbmt/pact/native/logger"

module Sbmt
  module Pact
    module Consumer
      class Grpc
        class PluginInitError < Sbmt::Pact::FfiError; end

        class CreateInteractionError < Sbmt::Pact::FfiError; end

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/plugins/fn.pactffi_using_plugin.html
        INIT_PLUGIN_ERRORS = {
          1 => {reason: :internal_error, status: 1, description: "A general panic was caught"},
          2 => {reason: :plugin_load_failed, status: 2, description: "Failed to load the plugin"},
          3 => {reason: :invalid_handle, status: 3, description: "Pact Handle is not valid"}
        }.freeze

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/plugins/fn.pactffi_interaction_contents.html
        CREATE_INTERACTION_ERRORS = {
          1 => {reason: :internal_error, status: 1, description: "A general panic was caught"},
          2 => {reason: :mock_server_already_running, status: 2, description: "The mock server has already been started"},
          3 => {reason: :invalid_handle, status: 3, description: "The interaction handle is invalid"},
          4 => {reason: :invalid_content_type, status: 4, description: "The content type is not valid"},
          5 => {reason: :invalid_contents, status: 5, description: "The contents JSON is not valid JSON"},
          6 => {reason: :plugin_error, status: 6, description: "The plugin returned an error"}
        }.freeze

        PROTOBUF_PLUGIN_NAME = "protobuf"
        PROTOBUF_PLUGIN_VERSION = "0.3.5"
        GRPC_CONTENT_TYPE = "application/grpc"

        def initialize(consumer_name:, provider_name:, mock_server_host: "127.0.0.1", mock_server_port: 3009, log_level: :info)
          @pact = init_pact(consumer_name, provider_name, log_level: log_level)

          @mock_server_host = mock_server_host
          @mock_server_port = mock_server_port

          init_plugin!
        end

        def new_interaction(interaction, description, provider_state: nil, metadata: {})
          interaction_json = case interaction
          when Hash
            JSON.dump(interaction)
          when GrpcInteractionBuilder
            interaction.to_json
          else
            raise "unknown interaction format: should be Hash or GrpcInteractionBuilder"
          end

          message_pact = PactFfi::SyncMessageConsumer.new_interaction(@pact, description)
          provider_state && metadata.each_pair do |key, value|
            PactFfi.given_with_param(message_pact, provider_state, key.to_s, value.to_s)
          end

          result = PactFfi::PluginConsumer.interaction_contents(message_pact, 0, GRPC_CONTENT_TYPE, interaction_json)
          if CREATE_INTERACTION_ERRORS[result].present?
            error = CREATE_INTERACTION_ERRORS[result]
            raise CreateInteractionError.new("There was an error while trying to add interaction \"#{description}\"", error[:reason], error[:status])
          end

          @mock_server = MockServer.create_grpc(pact: @pact, host: @mock_server_host, port: @mock_server_port)

          self
        end

        def new_service_contact(service_name, proto_name, grpc_service, grpc_method)
          GrpcInteractionBuilder.new
            .with_service(Rails.root.join("deps/services/#{service_name}/grpc/#{proto_name}.proto").to_s, grpc_service, grpc_method)
        end

        def write_pacts!(dir)
          raise "mock server is not configured: please configure interaction with #new_interaction" unless defined?(@mock_server)

          @mock_server.write_pacts!(dir.to_s)
        end

        def matched?
          raise "mock server is not configured: please configure interaction with #new_interaction" unless defined?(@mock_server)

          @mock_server.matched?
        end

        def cleanup
          @mock_server&.cleanup
          PactFfi::PluginConsumer.cleanup_plugins(@pact)
          PactFfi.free_pact_handle(@pact)
        end

        private

        def init_pact(consumer_name, provider_name, log_level:)
          handle = PactFfi.new_pact(consumer_name, provider_name)
          PactFfi.with_specification(handle, PactFfi::FfiSpecificationVersion["SPECIFICATION_VERSION_V4"])
          PactFfi.with_pact_metadata(handle, "sbmt-pact", "pact-ffi", PactFfi.version)

          Sbmt::Pact::Native::Logger.log_to_stdout(log_level)

          handle
        end

        def init_plugin!
          result = PactFfi::PluginConsumer.using_plugin(@pact, PROTOBUF_PLUGIN_NAME, PROTOBUF_PLUGIN_VERSION)
          return result if INIT_PLUGIN_ERRORS[result].blank?

          error = INIT_PLUGIN_ERRORS[result]
          raise PluginInitError.new("There was an error while trying to initialize plugin #{PROTOBUF_PLUGIN_NAME}/#{PROTOBUF_PLUGIN_VERSION}", error[:reason], error[:status])
        end
      end
    end
  end
end
