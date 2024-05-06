# frozen_string_literal: true

class PetStoreGrpcConfig < Sbmt::App::Grpc::Client::Config
  config_name :pet_store_grpc
  env_prefix :pet_store_grpc
end
