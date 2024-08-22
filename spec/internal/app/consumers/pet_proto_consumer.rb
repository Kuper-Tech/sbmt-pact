# frozen_string_literal: true

require "sbmt/kafka_consumer"

class PetProtoConsumer < Sbmt::KafkaConsumer::BaseConsumer
  def process_message(message)
    Rails.logger.info "Pet ID: #{message.payload.id}"
  end
end
