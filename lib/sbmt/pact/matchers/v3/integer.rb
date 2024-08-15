# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Integer < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of Integer" unless value.is_a?(::Integer)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, serializer: serializer, kind: "integer", value: value)
          end
        end
      end
    end
  end
end
