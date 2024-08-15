# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Serializers
        class Basic < Serializers::Base
          def self.call(matcher_instance, *args)
            raise SerializerInitializationError, "matcher_instance should be instance of Sbmt::Pact::Matchers::Base" unless matcher_instance.is_a?(Sbmt::Pact::Matchers::Base)

            {
              "pact:matcher:type" => matcher_instance.kind.to_s,
              "value" => matcher_instance.value
            }.merge(matcher_instance.opts).to_json(*args)
          end
        end
      end
    end
  end
end
