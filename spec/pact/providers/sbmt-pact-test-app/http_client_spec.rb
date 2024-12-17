# frozen_string_literal: true

require "sbmt/pact/rspec"

RSpec.describe "Sbmt::Pact::Providers::Test::HttpClient", :pact do
  has_http_pact_between "sbmt-pact-test-app", "sbmt-pact-test-app"

  let(:pet_id) { 123 }
  let(:host) { "127.0.0.1:3000" }
  let(:interaction) { new_interaction }
  let(:http_client) do
    Faraday.new do |conn|
      conn.response :json
      conn.request :json
    end
  end

  context "with GET /pets/:id" do
    let(:make_request) do
      http_client.get("http://#{host}/pets/#{pet_id}")
    end

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
    let(:make_request) do
      http_client.patch("http://#{host}/pets/#{pet_id}", pet_data.to_json,
        {"Authorization" => "some-token"})
    end
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
