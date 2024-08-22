# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V4
        class NotEmpty < Sbmt::Pact::Matchers::Base
          def initialize(template)
            raise MatcherInitializationError, "#{self.class}: #{template} should not be empty" if template.blank?

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V4, kind: "time", template: template)
          end
        end
      end
    end
  end
end
