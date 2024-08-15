# frozen_string_literal: true

require "sbmt/pact/rspec"
require "internal/config/configs/pet_store_grpc_config"

RSpec.describe "Sbmt::Pact::Providers::Test::GrpcClient", :pact do
  include Anyway::Testing::Helpers

  has_grpc_pact_between "sbmt-pact-test-app", "sbmt-pact-test-app"

  let(:pet_id) { 123 }

  let(:api) { PetStore::Grpc::PetStore::V1::PetsApi.new }
  let(:make_request) { api.pet_by_id(id: pet_id) }

  let(:interaction) do
    new_interaction
      .with_service("spec/internal/deps/services/pet_store/grpc/pet_store.proto", "Pets/PetById")
  end

  context "with Pets/PetById" do
    context "with successful interaction" do
      let(:interaction) do
        super()
          .given("pet exists", pet_id: pet_id)
          .with_request(id: match_any_integer(pet_id))
          .with_response(
            pet: {
              id: match_any_integer, name: match_any_string
            }
          )
      end

      it "executes the pact test without errors" do
        interaction.execute do
          expect(make_request).to be_success
        end
      end
    end
  end
end
