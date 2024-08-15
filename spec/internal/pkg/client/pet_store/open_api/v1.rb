# frozen_string_literal: true

module PetStore
  module OpenApi
    module V1
      Dir[File.join(__dir__, "v1/api/*.rb")].each { |f| require_dependency f }
      Dir[File.join(__dir__, "v1/models/*.rb")].each { |f| require_dependency f }
    end
  end
end
