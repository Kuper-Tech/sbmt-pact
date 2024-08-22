# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Number < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Numeric" unless template.is_a?(Numeric)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, kind: "number", template: template)
          end
        end
      end
    end
  end
end
