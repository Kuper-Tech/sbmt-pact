# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class Include < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of String" unless template.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, kind: "include", template: template)
          end
        end
      end
    end
  end
end
