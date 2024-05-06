# frozen_string_literal: true

module PetStore
  module Grpc
    module PetStore::V1
      # You can use this class to call any GRPC methods declared
      # in the `PetStore::Grpc::PetStore::V1::Pets::Service` GRPC service
      # within the `deps/services/pet_store/grpc/pet_store.v1.proto` file
      # For each GRPC method, an instance method named in CamelCase will be added to this class
      # @example
      #   grpc_module = PetStore::Grpc::PetStore::V1
      #   api = grpc_module::PetsApi.new
      #   # Suppose a contract has a `rpc GetSomeDataById (SomeRequest) returns (SomeResponse);` method
      #   result = api.get_some_data_by_id(grpc_module::SomeRequest.new(id: id)
      #   case result
      #   in Success(some_response)
      #     do_something(some_response.response_attr)
      #   in Failure(code, message)
      #     handle_error(code, message)
      #   end
      class PetsApi < Sbmt::App::Grpc::Client::BaseApi
        # You can override the generated methods for GRPC requests here, e.g.:
        # def get_some_data_by_id(id)
        #   request = SomeRequest.new(id: id)
        #
        #   super(request)
        # end
      end
    end
  end
end
