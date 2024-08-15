# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V2
        class Type < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: value is not a primitive" unless value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V2, serializer: serializer, kind: "type", value: value)
          end
        end
      end
    end
  end
end
