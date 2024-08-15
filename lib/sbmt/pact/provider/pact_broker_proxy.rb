# frozen_string_literal: true

require "rack-proxy"

module Sbmt
  module Pact
    module Provider
      class PactBrokerProxy < Rack::Proxy
        attr_reader :backend_uri, :path, :filter_type, :logger

        # e.g. /pacts/provider/paas-stand-seeker/consumer/paas-stand-placer/pact-version/2967a9343bd8fdd28a286c4b8322380020618892/metadata/c1tdW2VdPXByb2R1Y3Rpb24mc1tdW2N2XT03MzIy
        PACT_FILE_REQUEST_PATH_REGEX = %r{/pacts/provider/.+?/consumer/.+?/pact-version/.+}.freeze

        def initialize(app = nil, opts = {})
          super
          @backend_uri = URI(opts[:backend])
          @path = nil
          @filter_type = opts[:filter_type]
          @logger = opts[:logger] || Logger.new($stdout)
        end

        def perform_request(env)
          request = Rack::Request.new(env)
          @path = request.path

          super
        end

        def rewrite_env(env)
          env["HTTP_HOST"] = backend_uri.host
          env
        end

        def rewrite_response(triplet)
          status, headers, body = triplet

          if status == "200" && PACT_FILE_REQUEST_PATH_REGEX.match?(path)
            patched_body = patch_response(body.first)

            # we need to recalculate content length
            headers[Rack::CONTENT_LENGTH] = patched_body.bytesize.to_s

            return [status, headers, [patched_body]]
          end

          triplet
        end

        private

        def patch_response(raw_body)
          parsed_body = JSON.parse(raw_body)

          return body if parsed_body["consumer"].blank? || parsed_body["provider"].blank?
          return body if parsed_body["interactions"].blank?

          filter_interactions(parsed_body)

          JSON.generate(parsed_body)
        rescue JSON::ParserError => ex
          logger.error("cannot parse broker response: #{ex.message}")
        end

        def filter_interactions(pact_json_hash)
          return pact_json_hash unless filter_type

          pact_json_hash["interactions"].each do |interaction|
            set_description_prefix(interaction, "grpc:") if interaction["transport"] == "grpc" && filter_type == :grpc
            set_description_prefix(interaction, "http:") if interaction["transport"] == "http" && filter_type == :http
            set_description_prefix(interaction, "http:") if interaction["type"] == "Synchronous/HTTP" && filter_type == :http
            set_description_prefix(interaction, "async:") if interaction["type"] == "Asynchronous/Messages" && filter_type == :async
            set_description_prefix(interaction, "sync:") if interaction["type"] == "Synchronous/Messages" && filter_type == :sync
          end

          pact_json_hash
        end

        def set_description_prefix(interaction, prefix)
          orig_description = interaction["description"]
          interaction["description"] = "#{prefix} #{orig_description}" unless orig_description.start_with?(prefix)
        end
      end
    end
  end
end
