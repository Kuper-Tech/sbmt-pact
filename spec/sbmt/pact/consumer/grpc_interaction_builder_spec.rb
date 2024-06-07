# frozen_string_literal: true

RSpec.describe Sbmt::Pact::Consumer::GrpcInteractionBuilder do
  subject { described_class.new(nil) }

  let(:proto_path) { Rails.root.join("deps/services/pet_store/grpc/pet_store.proto").to_s }
  let(:builder) do
    subject
      .with_service(proto_path, "Pets/PetById")
      .with_request(param: "some data")
      .with_response(result: "some data")
  end

  it "builds proper json" do
    result = JSON.parse(builder.interaction_json)
    expect(result).to eq(
      "pact:content-type" => "application/protobuf",
      "pact:proto" => File.expand_path(proto_path).to_s,
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
