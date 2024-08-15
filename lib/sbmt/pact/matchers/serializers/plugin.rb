# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Serializers
        class Plugin < Serializers::Base
          class << self
            def call(matcher_instance, *args)
              raise SerializerInitializationError, "matcher_instance should be instance of Sbmt::Pact::Matchers::Base" unless matcher_instance.is_a?(Sbmt::Pact::Matchers::Base)

              kind = matcher_instance.kind.to_s
              params = matcher_instance.opts.values.map { |v| format_primitive(v) }.join(",")
              value = format_primitive(matcher_instance.value)

              return JSON.dump("matching(#{kind}, #{params}, #{value})") if params.present?

              JSON.dump("matching(#{kind}, #{value})")
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
    end
  end
end
