# frozen_string_literal: true

module PactProviderHelpers
  def new_grpc_verifier(**args)
    Sbmt::Pact::Provider::GrpcVerifier.new(**args)
  end
end

RSpec.configure do |config|
  config.include PactProviderHelpers, pact_entity: :provider
end
