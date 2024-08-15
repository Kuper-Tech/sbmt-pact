# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Include < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of String" unless value.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, serializer: serializer, kind: "include", value: value)
          end
        end
      end
    end
  end
end
