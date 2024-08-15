# frozen_string_literal: true

require "sbmt/pact/rspec"
require "internal/config/configs/pet_store_open_api_config"

RSpec.describe "Sbmt::Pact::Providers::Test::HttpClient", :pact do
  include Anyway::Testing::Helpers

  has_http_pact_between "sbmt-pact-test-app", "sbmt-pact-test-app"

  let(:pet_id) { 123 }
  let(:api) { PetStore::OpenApi::V1::PetsApi.new }
  let(:interaction) { new_interaction }

  context "with GET /pets/:id" do
    let(:make_request) { api.pets_id_get(pet_id) }

    context "with successful interaction" do
      let(:interaction) do
        super()
          .given("pet exists", pet_id: pet_id)
          .upon_receiving("getting a pet")
          .with_request(:get, "/pets/#{pet_id}")
          .with_response(200, body: {
            pet: {
              id: match_any_integer(pet_id),
              bark: match_any_boolean(true),
              breed: match_any_string("Husky")
            }
          })
      end

      it "executes the pact test without errors" do
        interaction.execute do
          expect(make_request).to be_success
        end
      end
    end
  end

  context "with PATCH /pets" do
    let(:make_request) { api.pets_id_patch(pet_id, pet: pet, header_params: {"Authorization" => "some-token"}) }
    let(:pet) { PetStore::OpenApi::V1::Dog.new(pet_data) }
    let(:pet_data) { {breed: "Shepherd"} }

    context "with successful interaction" do
      let(:interaction) do
        super()
          .given("pet exists", pet_id: pet_id)
          .upon_receiving("updating a pet")
          .with_request(:patch, "/pets/#{pet_id}",
            headers: {Authorization: match_any_string("some-token")},
            body: pet_data)
          .with_response(200,
            headers: {TRACE_ID: match_any_string("xxx-xxx")},
            body: {
              pet: {
                id: match_any_integer(pet_id),
                bark: match_any_boolean(true),
                breed: match_any_string("Shepherd")
              }
            })
      end

      it "executes the pact test without errors" do
        interaction.execute do
          expect(make_request).to be_success
        end
      end
    end
  end
end
