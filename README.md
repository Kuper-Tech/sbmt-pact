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

## Архитектура

![Архитектура](docs/sbmt-pact-arch.png)

- DSL - реализация rspec-DSL для удобства написания пакт-тестов
- matchers - реализация пакт-матчеров, представляет собой удобные хелперы, используемые в consumer-DSL, инкапсулирующие в себе всю логику сериализации в pact-формат
- mock servers - мок-серверы, которые позволяют корректно запускать провайдер-тесты

## DSL консюмер-тестов

Для каждого типа взаимодействий (из-за их особенностей) реализована своя версия DSL, однако общие принципы одинаковы для каждого типа взаимодействий

```ruby

# декларация консюмер-теста, обязательно указываем  тэг :pact,
# это используется в CI/CD пайплайнах для разделения пакт-тестов от остальных rspec
# пакт-тесты не запускаются в рамках общего пайплайна rspec
RSpec.describe "SomePactConsumerTestForAnyTransport", :pact do
  # декларация типа взаимодействия - тут определяем, какие консюмер и провайдер по какому транспорту взаимодействуют
  has_http_pact_between "CONSUMER-NAME", "PROVIDER-NAME"
  # или
  has_grpc_pact_between "CONSUMER-NAME", "PROVIDER-NAME"
  # или
  has_message_pact_between "CONSUMER-NAME", "PROVIDER-NAME"

  # контекст для одного из взаимодействий, например GET /api/v2/stores
  context "with GET /api/v2/stores" do
      let(:interaction) do
        # создаем новой взаимодействие - в рамках которого описываем контракт
        new_interaction
          # если необходимо сохранить какие-либо метаданные для последующего их использования провайдер-тестом,
          # например, указать ID сущности, которую нужно будет предсоздать в БД в провайдер-тесте
          # используем provider states - см. https://docs.pact.io/getting_started/provider_states
          .given("UNIQUE PROVIDER STATE", key1: value1, key2: value2)
          # описание взаимодействия, используется для идентификации внутри пакт-обвязки, 
          # в некоторых случаях опционально, но рекомендуется указывать всегда
          .upon_receiving("UNIQUE INTERACTION DESCRIPTION")
          # описание запроса с использованием матчеров
          # имя и параметры метода отличаются для разных транспортов, подробнее см. отдельные разделы
          .with_request(...)
          # описание ответа с использованием матчеров
          # имя и параметры метода отличаются для разных транспортов, подробнее см. отдельные разделы
          .with_response(...)
          # далее есть отличия для разных типов транспортов, подробнее см. отдельные разделы
      end

      it "executes the pact test without errors" do
        interaction.execute do
          # тут происходит вызов нашего клиента для тестируемого API
          # в данном контексте клиентом может быть: http-клиент, grpc-клиент, кафка-консюмер
          # подробнее см. отдельные разделы
          expect(make_request).to be_success
        end
      end
    end
  end

```

Общие методы DSL:
- `new_interaction` - инициализирует новое взаимодействие
- `given` - позволяет указать provider state с параметрами и без, подробнее см. в https://docs.pact.io/getting_started/provider_states
- `upon_receiving` - позволяет указать название взаимодействия

### DSL http-консюмеров

Специфичные методы DSL:
- `with_request(HTTP_METHOD, QUERY_PATH, {headers: kv_hash, body: kv_hash})` - описание запроса
- `with_response(HTTP_STATUS, {headers: kv_hash, body: kv_hash})` - описание ответа

Подробнее в [http_client_spec.rb](spec/pact/providers/sbmt-pact-test-app/http_client_spec.rb)

### DSL grpc-консюмеров

Специфичные методы DSL:
- `with_service(PROTO_PATH, RPC_SERVICE_AND_ACTION)` - указывает используемый контракт, PROTO_PATH - относительный от Rails.root
- `with_request(request_kv_hash)` - описание запроса
- `with_response(response_kv_hash)` - описание ответа

Подробнее в [grpc_client_spec.rb](spec/pact/providers/sbmt-pact-test-app/grpc_client_spec.rb)

### DSL kafka-консюмеров

Специфичные методы DSL:
- `with_headers(kv_hash)` - для указания кафка-хедеров, можно использовать матчеры
- `with_metadata(kv_hash)` - для указания метаданных (специальные ключи `key` и `topic`, где соотв-но можно указать матчеры для ключа партиционирования и топика в кафке)

Далее специфика - один из двух вариантов описания формата:
JSON (для описания сообщения в JSON представлении):
- `with_json_contents(kv_hash)` - описание формата сообщения

PROTO (для описания сообщения в protobuf представлении):
- `with_proto_class(PROTO_PATH, PROTO_MESSAGE_NAME)` - указывает используемый контракт, PROTO_PATH - относительный от Rails.root, PROTO_MESSAGE_NAME - название используемого message из proto-файла
- `with_proto_contents(kv_hash)` - описание формата сообщения

Подробнее в [kafka_spec.rb](spec/pact/providers/sbmt-pact-test-app/kafka_spec.rb)

### Матчеры

Матчеры - это специальные хелпер-методы, позволяющие на уровне пакт-манифеста определять правила соответствия параметров запросов / ответов.
Матчеры описаны в спецификациях пакт, подробнее см. в https://github.com/pact-foundation/pact-specification
В данном геме матчеры реализованы в виде rspec-хелперов.

Детали реализации см. в [matchers.rb](lib/sbmt/pact/matchers.rb)

- `match_exactly(sample)` - позволяет матчить точное значение, указанное в sample
- `match_type_of(sample)` - позволяет матчить тип данных (integer, string, boolean), указанный в sample
- `match_include(sample)` - позволяет матчить подстроку
- `match_any_string(sample)` - позволяет матчить любую строку, из-за особенностей тут также будут сматчены null и пустые строки
- `match_any_integer(sample)` - позволяет матчить любой integer
- `match_any_decimal(sample)` - позволяет матчить float/double
- `match_any_number(sample)` - позволяет матчить любой integer, float, double
- `match_any_boolean(sample)` - позволяет матчить boolean значения true/false
- `match_uuid(sample)` - позволяет матчить UUID (под капотом используется `match_regex`)
- `match_regex(regex, sample)` - позволяет матчить по regexp
- `match_datetime(format, sample)` - позволяет матчить подстроку
- `match_iso8601(sample)` - позволяет матчить формат ISO8601 (матчер не полностью соответствует ISO8601, матчит только самые распространенные варианты, под капотом используется `match_regex`)
- `match_date(format, sample)` - позволяет матчить дату по формату (rust datetime)
- `match_time(format, sample)` - позволяет матчить время по формату (rust datetime)
- `match_each(template)` - позволяет матчить все элементы массива по указанному template, можно использовать для вложенных элементов
- `match_each_regex(regex, sample)` - позволяет матчить все элементы массива по regex, используется для массивов со строковыми элементами
- `match_each_key(template, key_matchers)` - позволяет матчить каждый ключ хэша по указанному template
- `match_each_value(template)` - позволяет матчить каждое значение хэша по указанному template, можно использовать для вложенных элементов
- `match_each_kv(template, key_matchers)` - позволяет матчить все ключи/значения хэша по указанным template и key_matchers, можно использовать для вложенных элементов

См. разные варианты использования матчеров в [matchers_spec.rb](spec/sbmt/pact/matchers_spec.rb)

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
