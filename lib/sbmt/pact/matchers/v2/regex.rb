# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V2
        class Regex < Sbmt::Pact::Matchers::Base
          def initialize(serializer, regex, value)
            raise MatcherInitializationError, "#{self.class}: #{regex} should be an instance of Regexp" unless regex.is_a?(Regexp)
            raise MatcherInitializationError, "#{self.class}: #{value} should be an instance of String" unless value.is_a?(String)

            super(spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V2, serializer: serializer, kind: "regex", value: value, opts: {regex: regex.to_s})
          end
        end
      end
    end
  end
end
