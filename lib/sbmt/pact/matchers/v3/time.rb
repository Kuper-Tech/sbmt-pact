# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Time < Sbmt::Pact::Matchers::Base
          def initialize(serializer, format, value)
            raise MatcherInitializationError, "#{self.class}: #{format} should be an instance of String" unless value.is_a?(String)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of String" unless value.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, serializer: serializer, kind: "time", value: value, opts: {format: format})
          end
        end
      end
    end
  end
end
