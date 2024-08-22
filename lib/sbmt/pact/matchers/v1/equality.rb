# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V1
        class Equality < Sbmt::Pact::Matchers::Base
          def initialize(template)
            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V1, kind: "equality", template: template)
          end

          def as_plugin
            "matching(equalTo, #{format_primitive(@template)})"
          end
        end
      end
    end
  end
end
