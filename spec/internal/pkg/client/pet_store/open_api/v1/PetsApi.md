# PetStore::OpenApi::V1::PetsApi

All URIs are relative to */api/v3*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**pets_id_get**](PetsApi.md#pets_id_get) | **GET** /pets/{id} |  |
| [**pets_id_patch**](PetsApi.md#pets_id_patch) | **PATCH** /pets/{id} |  |


## pets_id_get

> <Pet> pets_id_get(id)



### Examples

```ruby
require 'time'
require 'pet_store_open_api_v1'

api_instance = PetStore::OpenApi::V1::PetsApi.new
id = 56 # Integer | ID of pet to return

result = api_instance.pets_id_get(id)
p result
```

#### Using the pets_id_get_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Pet>, Integer, Hash)> pets_id_get_with_http_info(id)

```ruby

data, status_code, headers = api_instance.pets_id_get_with_http_info(id)
p status_code # => 2xx
p headers # => { ... }
p data.value! # => <Pet>
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **id** | **Integer** | ID of pet to return |  |

### Return type

[**Pet**](Pet.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## pets_id_patch

> <Pet> pets_id_patch(id, opts)



### Examples

```ruby
require 'time'
require 'pet_store_open_api_v1'

api_instance = PetStore::OpenApi::V1::PetsApi.new
id = 56 # Integer | ID of pet to return
opts = {
  pet: PetStore::OpenApi::V1::Cat.new # Pet | 
}

result = api_instance.pets_id_patch(id, opts)
p result
```

#### Using the pets_id_patch_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Pet>, Integer, Hash)> pets_id_patch_with_http_info(id, opts)

```ruby

data, status_code, headers = api_instance.pets_id_patch_with_http_info(id, opts)
p status_code # => 2xx
p headers # => { ... }
p data.value! # => <Pet>
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **id** | **Integer** | ID of pet to return |  |
| **pet** | [**Pet**](Pet.md) |  | [optional] |

### Return type

[**Pet**](Pet.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

