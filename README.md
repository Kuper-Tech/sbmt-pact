# Sbmt Pact

## Функционал

На данный момент существующая версия гема `pact-ruby` поддерживает [Pact Specification](https://github.com/pact-foundation/pact-specification) лишь версий v1 и v2, что не позволяет:
- написание контрактных тестов для async messages (kafka, etc)
- написание контрактных тестов с отличными от http транспортами (например, grpc)

Гем `pact-ruby` более не поддерживается меинтейнерами, так как произошел переход к [rust-core](https://github.com/pact-foundation/pact-reference), который в отличных от rust стеков предполагается использовать через FFI

Данный гем позволяет избавиться от вышеперечисленных недостатков и реализует поддержку последних версий pact-спецификаций:
- базируется на [pact-ffi](https://github.com/pact-foundation/pact-reference/releases) и [pact-ruby-ffi](https://github.com/YOU54F/pact-ruby-ffi)
- предоставляет удобный DSL, упрощающий написание контрактных тестов в ruby/rspec
- поддерживает pact-broker и существующие gitlab-пайплайны в PaaS

## Разработка

### Локальное окружение

1. Подготовка рабочего окружения
```shell
dip provision
```

2. Запуск тестов
```shell
dip rspec
```
