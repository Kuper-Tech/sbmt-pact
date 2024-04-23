# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
      ANY_STRING_REGEX = /.+/

      def pact_match_uuid(sample = "e1d01e04-3a2b-4eed-a4fb-54f5cd257338")
        pact_match(UUID_REGEX, sample)
      end

      def pact_match_include(arg)
        "matching(include, '#{arg}')"
      end

      def pact_match_any_string(sample = "any")
        pact_match(ANY_STRING_REGEX, sample)
      end

      def pact_match(arg, sample = nil)
        case arg
        when TrueClass, FalseClass
          "matching(boolean, #{sample || arg.to_s})"
        when Integer
          "matching(integer, #{sample || arg.to_s})"
        when Float
          "matching(decimal, #{sample || arg.to_s})"
        when Numeric
          "matching(number, #{sample || arg.to_s})"
        when String
          "matching(equalTo, '#{sample || arg.to_s}')"
        when Regexp
          "matching(regex, '#{arg}', '#{sample || arg.to_s}')"
        else
          raise "pact matching for #{arg.class} is not supported yet"
        end
      end
    end
  end
end
