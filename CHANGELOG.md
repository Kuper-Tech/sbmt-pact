# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

### Added

### Changed

### Fixed

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
