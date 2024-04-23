# frozen_string_literal: true

require "pact/ffi/sync_message_consumer"
require "pact/ffi/plugin_consumer"
require "pact/ffi/logger"

module Sbmt
  module Pact
    module Consumer
      class GrpcInteractionBuilder
        def initialize
          @proto_path = nil
          @service_name = nil
          @method_name = nil
          @request = nil
          @response = nil
        end

        def with_service(proto_path, service_name, method_name)
          @proto_path = proto_path
          @service_name = service_name
          @method_name = method_name
          self
        end

        def with_request(req_hash)
          @request = req_hash
          self
        end

        def with_response(resp_hash)
          @response = resp_hash
          self
        end

        def with_response_meta(meta_hash)
          @response_meta = meta_hash
          self
        end

        def to_json
          validate!

          base = {
            "pact:proto": @proto_path,
            "pact:proto-service": "#{@service_name}/#{@method_name}",
            "pact:content-type": "application/protobuf",
            request: @request
          }

          result = if @response_meta.is_a?(Hash)
            base.merge(responseMetadata: @response_meta)
          else
            base.merge(response: @response)
          end

          JSON.dump(result)
        end

        def validate!
          raise "uninitialized service params, use #with_service to configure" if @proto_path.blank? || @service_name.blank? || @method_name.blank?
          raise "invalid request format, should be a hash" unless @request.is_a?(Hash)
          raise "invalid response format, should be a hash" unless @response.is_a?(Hash) || @response_meta.is_a?(Hash)
        end
      end
    end
  end
end
