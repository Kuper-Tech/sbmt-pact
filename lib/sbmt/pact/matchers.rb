# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
      ANY_STRING_REGEX = /.*/

      # high-level pact plugin matchers below

      def match_exactly(arg)
        pact_match_eql(arg)
      end

      def match_type_of(arg)
        pact_match_type(arg)
      end

      def match_include(arg)
        pact_match_include(arg)
      end

      def match_any_string(sample = "any")
        match_regex(ANY_STRING_REGEX, sample)
      end

      def match_any_integer(sample = 10)
        pact_match_integer(sample)
      end

      def match_any_decimal(sample = 10.0)
        pact_match_decimal(sample)
      end

      def match_any_number(sample = 10.0)
        pact_match_numeric(sample)
      end

      def match_any_boolean(sample = true)
        pact_match_boolean(sample)
      end

      def match_uuid(sample = "e1d01e04-3a2b-4eed-a4fb-54f5cd257338")
        match_regex(UUID_REGEX, sample)
      end

      def match_regex(regex, sample)
        pact_match_regex(regex, sample)
      end

      def match_datetime(format, sample)
        pact_match_datetime(format, sample)
      end

      def match_date(format, sample)
        pact_match_datetime(format, sample)
      end

      def match_time(format, sample)
        pact_match_datetime(format, sample)
      end

      # low-level pact plugin matchers below
      # see https://github.com/pact-foundation/pact-plugins/blob/main/docs/matching-rule-definition-expressions.md

      def pact_match_all(*matchers)
        raise "matchers are empty" if matchers.blank?
        matchers.join(", ")
      end

      def pact_match_not_empty(sample)
        "notEmpty(#{format_primitive(sample)})"
      end

      def pact_match_eql(sample)
        "matching(equalTo, #{format_primitive(sample)})"
      end

      def pact_match_type(arg)
        "matching(type, #{format_primitive(arg)})"
      end

      def pact_match_boolean(sample)
        raise "#{sample} is not a boolean" unless sample.is_a?(TrueClass) || sample.is_a?(FalseClass)
        "matching(boolean, #{format_primitive(sample)})"
      end

      def pact_match_integer(sample)
        raise "#{sample} is not an integer" unless sample.is_a?(Integer)
        "matching(integer, #{format_primitive(sample)})"
      end

      def pact_match_decimal(sample)
        raise "#{sample} is not a float" unless sample.is_a?(Float)
        "matching(decimal, #{format_primitive(sample)})"
      end

      def pact_match_numeric(sample)
        raise "#{sample} is not a number" unless sample.is_a?(Numeric)
        "matching(number, #{format_primitive(sample)})"
      end

      def pact_match_include(sample)
        raise "#{sample} is not a string" unless sample.is_a?(String)
        "matching(include, #{format_primitive(sample)})"
      end

      def pact_match_regex(regex, sample)
        raise "#{regex} is not a Regexp" unless regex.is_a?(Regexp)
        raise "#{sample} is not a string" unless sample.is_a?(String)
        "matching(regex, #{format_primitive(regex.to_s)}, #{format_primitive(sample)})"
      end

      def pact_match_datetime(format, sample)
        raise "#{format} is not a string" unless format.is_a?(String)
        raise "#{sample} is not a string" unless sample.is_a?(String)
        "matching(datetime, #{format_primitive(format)}, #{format_primitive(sample)})"
      end

      def pact_match_date(format, sample)
        raise "#{format} is not a string" unless format.is_a?(String)
        raise "#{sample} is not a string" unless sample.is_a?(String)
        "matching(datetime, #{format_primitive(format)}, #{format_primitive(sample)})"
      end

      def pact_match_time(format, sample)
        raise "#{format} is not a string" unless format.is_a?(String)
        raise "#{sample} is not a string" unless sample.is_a?(String)
        "matching(datetime, #{format_primitive(format)}, #{format_primitive(sample)})"
      end

      private

      def format_primitive(arg)
        case arg
        when TrueClass, FalseClass, Numeric
          arg.to_s
        when String
          "'#{arg}'"
        else
          raise "#{arg.class} is not a primitive"
        end
      end
    end
  end
end
