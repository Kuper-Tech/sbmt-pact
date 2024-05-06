# frozen_string_literal: true

RSpec.describe Sbmt::Pact::Consumer::GrpcInteractionBuilder do
  let(:builder) do
    subject
      .with_service("deps/services/pet_store/grpc/pet_store.proto", "Pets", "PetById")
      .with_request(param: "some data")
      .with_response(result: "some data")
  end

  it "builds proper json" do
    result = JSON.parse(builder.to_json)
    expect(result).to eq(
      "pact:content-type" => "application/protobuf",
      "pact:proto" => "deps/services/pet_store/grpc/pet_store.proto",
      "pact:proto-service" => "Pets/PetById",
      "request" => {
        "param" => "some data"
      },
      "response" => {
        "result" => "some data"
      }
    )
  end
end
