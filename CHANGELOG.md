# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

### Added

### Changed

- Remove sbmt-dev

### Fixed

## [0.12.1] - 2024-12-12

### Changed
- replaced localhost to 127.0.0.1 for provider tests

## [0.12.0] - 2024-09-11

# Changed
- remove internal deps

## [0.11.1] - 2024-08-22

### Fixed
- the `verify_only` config option is now set based on the `PACT_CONSUMER_FULL_NAME` environment variable.
- if the current `consumer_name` does not match the `verify_only` option, then the consumer verification is skipped

## [0.11.0] - 2024-08-07

### Added
- async messages support
- collection matchers
- support of additional includes of proto-files for grpc plugin

## [0.10.0] - 2024-08-15

### Added
- HTTP Rspec DSL

## [0.9.0] - 2024-08-03

### Added
- pact-broker-proxy to filter proper transport types in specs
- ability to run pact-tests on CI + dip

### Fixed
- refactor matchers

## [0.8.0] - 2024-07-04

### Added
- Use `deployed: true` for default consumer selectors instead master branch

## [0.7.0] - 2024-06-21

### Added
- Ability to limit consumers to verify with provider

### Fixed
- Changed pact-specs rspec meta (`type: :pact` => `pact: true`) for compatibility with legacy pact-ruby / older rspec
- Bump used pact-protobuf-plugin version to 0.4.0
- `match_any_string` now matches empty strings
- limit pact:verify specs only to consumer pact-tests dir

## [0.6.0] - 2024-06-05

### Fixed
- GRPC producer DSL (rspec) refined

## [0.5.0] - 2024-06-05

### Fixed
- GRPC consumer DSL (rspec) refined
- plugin matchers refined

## [0.4.1] - 2024-06-06

### Fixed
- Use proper consumer version for provider verification

## [0.4.0] - 2024-05-29

### Added
- Ability to verify provider specs against pact-broker

## [0.3.0] - 2024-05-03

### Added
- Provider specs base DSL/helpers

## [0.2.0] - 2024-04-18

### Added
- Consumer specs base DSL/helpers

## [Unreleased]

## [0.1.0] - 2024-04-12

- Initial release
