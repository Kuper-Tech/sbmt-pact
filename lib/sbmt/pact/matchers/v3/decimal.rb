# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Decimal < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of Float" unless value.is_a?(Float)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, serializer: serializer, kind: "decimal", value: value)
          end
        end
      end
    end
  end
end
