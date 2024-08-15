# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      # see https://github.com/pact-foundation/pact-reference/blob/master/rust/pact_ffi/IntegrationJson.md
      class Base
        attr_reader :spec_version, :kind, :value, :opts

        class MatcherInitializationError < Sbmt::Pact::Error; end

        def initialize(spec_version:, serializer:, kind:, value:, opts: {})
          @spec_version = spec_version
          @serializer = serializer
          @kind = kind
          @value = value
          @opts = opts
        end

        def to_json(*args)
          @serializer.call(self, *args)
        end
      end
    end
  end
end
