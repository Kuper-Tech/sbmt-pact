# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Integer < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of Integer" unless template.is_a?(::Integer)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, kind: "integer", template: template)
          end
        end
      end
    end
  end
end
