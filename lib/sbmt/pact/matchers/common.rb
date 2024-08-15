# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Common
        UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
        ANY_STRING_REGEX = /.*/

        def match_exactly(arg)
          Sbmt::Pact::Matchers::V1::Equality.new(serializer, arg)
        end

        def match_type_of(arg)
          Sbmt::Pact::Matchers::V2::Type.new(serializer, arg)
        end

        def match_include(arg)
          Sbmt::Pact::Matchers::V3::Include.new(serializer, arg)
        end

        def match_any_string(sample = "any")
          Sbmt::Pact::Matchers::V2::Regex.new(serializer, ANY_STRING_REGEX, sample)
        end

        def match_any_integer(sample = 10)
          Sbmt::Pact::Matchers::V3::Integer.new(serializer, sample)
        end

        def match_any_decimal(sample = 10.0)
          Sbmt::Pact::Matchers::V3::Decimal.new(serializer, sample)
        end

        def match_any_number(sample = 10.0)
          Sbmt::Pact::Matchers::V3::Number.new(serializer, sample)
        end

        def match_any_boolean(sample = true)
          Sbmt::Pact::Matchers::V3::Boolean.new(serializer, sample)
        end

        def match_uuid(sample = "e1d01e04-3a2b-4eed-a4fb-54f5cd257338")
          Sbmt::Pact::Matchers::V2::Regex.new(serializer, UUID_REGEX, sample)
        end

        def match_regex(regex, sample)
          Sbmt::Pact::Matchers::V2::Regex.new(serializer, regex, sample)
        end

        def match_datetime(format, sample)
          Sbmt::Pact::Matchers::V3::DateTime.new(serializer, format, sample)
        end

        def match_date(format, sample)
          Sbmt::Pact::Matchers::V3::Date.new(serializer, format, sample)
        end

        def match_time(format, sample)
          Sbmt::Pact::Matchers::V3::Time.new(serializer, format, sample)
        end

        def serializer; end
      end
    end
  end
end
