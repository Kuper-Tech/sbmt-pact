# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V4
        class NotEmpty < Sbmt::Pact::Matchers::Base
          def initialize(serializer, value)
            raise MatcherInitializationError, "#{self.class}: #{value} should not be empty" if value.blank?

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V4, serializer: serializer, kind: "time", value: value)
          end
        end
      end
    end
  end
end
