# frozen_string_literal: true

require "sbmt/kafka_consumer"

class PetJsonConsumer < Sbmt::KafkaConsumer::BaseConsumer
  def process_message(message)
    pet_id = message.payload["id"]
    Rails.logger.info "Pet ID: #{pet_id}"
  end
end
