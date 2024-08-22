# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Boolean < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Boolean" unless template.is_a?(TrueClass) || template.is_a?(FalseClass)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, kind: "boolean", template: template)
          end
        end
      end
    end
  end
end
