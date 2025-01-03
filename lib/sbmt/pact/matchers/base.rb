# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      # see https://github.com/pact-foundation/pact-reference/blob/master/rust/pact_ffi/IntegrationJson.md
      class Base
        attr_reader :spec_version, :kind, :template, :opts

        class MatcherInitializationError < Sbmt::Pact::Error; end

        def initialize(spec_version:, kind:, template:, opts: {})
          @spec_version = spec_version
          @kind = kind
          @template = template
          @opts = opts
        end

        def as_basic
          {
            "pact:matcher:type" => serialize!(@kind.deep_dup, :basic),
            "value" => serialize!(@template.deep_dup, :basic)
          }.merge(serialize!(@opts.deep_dup, :basic))
        end

        def as_plugin
          params = @opts.values.map { |v| format_primitive(v) }.join(",")
          value = format_primitive(@template)

          return "matching(#{@kind}, #{params}, #{value})" if params.present?

          "matching(#{@kind}, #{value})"
        end

        private

        def serialize!(data, format)
          # serialize complex types recursively
          case data
          when TrueClass, FalseClass, Numeric, String
            data
          when Array
            data.map { |v| serialize!(v, format) }
          when Hash
            data.transform_values { |v| serialize!(v, format) }
          when Sbmt::Pact::Matchers::Base
            return data.as_basic if format == :basic
            data.as_plugin if format == :plugin
          else
            data
          end
        end

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
end
