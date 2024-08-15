# frozen_string_literal: true

module Sbmt
  module Pact
    module Matchers
      module Basic
        include Common

        def serializer
          Sbmt::Pact::Matchers::Serializers::Basic
        end
      end
    end
  end
end
