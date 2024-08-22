# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module V4
        class EachKeyValue < Sbmt::Pact::Matchers::Base
          def initialize(key_matchers, template)
            raise MatcherInitializationError, "#{self.class}: #{template} should be a Hash" unless template.is_a?(Hash)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be an Array" unless key_matchers.is_a?(Array)
            raise MatcherInitializationError, "#{self.class}: #{key_matchers} should be instances of Sbmt::Pact::Matchers::Base" unless key_matchers.all?(Sbmt::Pact::Matchers::Base)

            super(
              spec_version: Sbmt::Pact::Matchers::PACT_SPEC_V4,
              kind: [
                EachKey.new(key_matchers, {}),
                EachValue.new([Sbmt::Pact::Matchers::V2::Type.new("")], {})
              ],
              template: template
            )

            @key_matchers = key_matchers
          end

          def as_plugin
            raise MatcherInitializationError, "#{self.class}: each-key-value is not supported in plugin syntax. Use each / each_key / each_value matchers instead"
          end
        end
      end
    end
  end
end
