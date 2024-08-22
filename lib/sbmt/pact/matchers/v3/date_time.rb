# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V3
        class DateTime < Sbmt::Pact::Matchers::Base
          def initialize(format, template)
            raise MatcherInitializationError, "#{self.class}: #{format} should be an instance of String" unless template.is_a?(String)
            raise MatcherInitializationError, "#{self.class}: #{template} should be an instance of String" unless template.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V3, kind: "datetime", template: template, opts: {format: format})
          end
        end
      end
    end
  end
end
