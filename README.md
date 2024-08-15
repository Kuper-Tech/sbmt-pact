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

#### Подготовка рабочего окружения
```shell
dip provision
```

#### Запуск unit-тестов
```shell
dip rspec
```

#### Запуск pact-тестов

Pact-тесты не запускаются в рамках общего rspec, их нужно запускать отдельно, см. ниже

##### Тесты консюмеров

```shell
dip pact consumer
```

или

```shell
bundle exec rspec -t pact spec/pact/providers/**/*_spec.rb
```

P.S. если ни разу не запускались - нужно запустить хотя бы раз, чтобы сгенерировать json-pact-манифесты, которые будут использоваться в провайдер-тестах (ниже)

##### Тесты провайдера

```shell
dip pact provider
```

или

```shell
bundle exec rspec -t pact spec/pact/consumers/*_spec.rb
```

##### Локальное использование pact-брокера

Если необходимо проверить возможность работать с пакт-брокером локально, нужно сделать следующее:
- поднять брокер

```shell
$ dip up pact-broker
```

- прогнать consumer-тесты, чтобы сгенерировать pact-манифест (будет создан в `spec/internal/pacts` по результатам успешного прохождения консюмер-тестов)

```shell
$ dip pact consumer
```

- опубликовать сгенерированный pact-манифест в pact-брокере

```shell
$ dip pact-cli publish
```

- для информации можно убедиться, что манифест опубликован, открыв в браузере http://localhost:9292 (не забыв пробросить порт 9292 на localhost, см. `docker-compose.yml`)
- запустить тесты провайдера, используя pact-брокер

```shell
$ dip pact provider-with-local-broker
```
