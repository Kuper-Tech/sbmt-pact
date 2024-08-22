# frozen_string_literal: true

require "sbmt/pact/rspec"

RSpec.describe "Sbmt::Pact::Consumers::Kafka", :pact do
  message_pact_provider "sbmt-pact-test-app"

  handle_message "pet message as json" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetJsonProducer.new(client: client).call(pet_id) }
  end

  handle_message "pet message as proto" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetProtoProducer.new(client: client).call(pet_id) }
  end
end
