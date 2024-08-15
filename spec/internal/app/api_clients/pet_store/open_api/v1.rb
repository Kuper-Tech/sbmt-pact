# frozen_string_literal: true

require Rails.root.join("pkg/client/pet_store/open_api/v1")

module PetStore
  module OpenApi
    module V1
      CONFIG = PetStoreOpenApiConfig

      class ApiClient < Sbmt::App::OpenApi::ApiClient
      end
    end
  end
end
