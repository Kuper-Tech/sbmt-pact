# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Boolean < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of Boolean" unless value.is_a?(TrueClass) || value.is_a?(FalseClass)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, serializer: serializer, kind: "boolean", value: value)
          end
        end
      end
    end
  end
end
