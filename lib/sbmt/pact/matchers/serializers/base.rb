# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Serializers
        class Base
          class SerializerInitializationError < Sbmt::Pact::Error; end

          def self.call(matcher_instance, *args)
            raise Sbmt::Pact::ImplementationRequired, "Implement #call in a subclass"
          end
        end
      end
    end
  end
end
