# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V1
        class Equality < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V1, serializer: serializer, kind: "equalTo", value: value)
          end
        end
      end
    end
  end
end
