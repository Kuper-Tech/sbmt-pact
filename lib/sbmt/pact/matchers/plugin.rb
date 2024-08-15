# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Plugin
        include Common

        def serializer
          Sbmt::Pact::Matchers::Serializers::Plugin
        end
      end
    end
  end
end
