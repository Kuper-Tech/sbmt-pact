# frozen_string_literal: true

module PactConsumerHelpers
  def new_grpc_pact(**args)
    Sbmt::Pact::Consumer::Grpc.new(**args)
  end
end

RSpec.configure do |config|
  config.include PactConsumerHelpers, pact_entity: :consumer
end
