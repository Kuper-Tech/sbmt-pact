# frozen_string_literal: true

require "internal/config/configs/pet_store_grpc_config"

describe Sbmt::Pact::Provider::GrufServer do
  let(:api) { PetStore::Grpc::PetStore::V1::PetsApi.new }
  let(:call_rpc) do
    subject.run { api.pet_by_id(PetStore::Grpc::PetStore::V1::PetByIdRequest.new(id: 1)) }
  end

  context "when success" do
    it "succeeds" do
      result = call_rpc
      expect(result).to be_success

      resp = result.value!
      expect(resp.pet.id).to eq 1
      expect(resp.pet.name).to eq "Jack"
    end
  end
end
