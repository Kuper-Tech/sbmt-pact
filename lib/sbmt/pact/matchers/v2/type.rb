# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V2
        class Type < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: template is not a primitive" unless template.is_a?(TrueClass) || template.is_a?(FalseClass) || template.is_a?(Numeric) || template.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V2, kind: "type", template: template)
          end
        end
      end
    end
  end
end
