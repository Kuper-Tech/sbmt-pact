# frozen_string_literal: true

require_relative "lib/sbmt/pact/version"

Gem::Specification.new do |spec|
  spec.name = "sbmt-pact"
  spec.license = "MIT"
  spec.version = Sbmt::Pact::VERSION
  spec.authors = ["Kuper Ruby Platform Team"]

  spec.summary = "Ruby gem for simplified Pact testing between microservices, supporting the latest Pact specifications and multiple transport protocols"
  spec.description = "It is a powerful Ruby gem designed to streamline Pact testing in microservice architectures. It supports the latest Pact specifications and offers capabilities beyond the current pact-ruby gem, including support for non-HTTP transports like gRPC and async messaging systems like Kafka."
  spec.homepage = "https://github.com/Kuper-Tech/sbmt-pact"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = ENV.fetch("NEXUS_URL", "https://rubygems.org")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "false" # rubocop:disable Gemspec/RequireMFA

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "zeitwerk", "~> 2.3"
  spec.add_dependency "pact-ffi", "~> 0.4.26"
  spec.add_dependency "rack", "~> 2.0"
  spec.add_dependency "webrick"
  spec.add_dependency "rack-proxy"

  spec.add_development_dependency "appraisal", ">= 2.4"
  spec.add_development_dependency "bundler", ">= 2.3"
  spec.add_development_dependency "combustion", ">= 1.3"
  spec.add_development_dependency "gruf", ">= 2.18"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "sbmt-kafka_consumer", ">= 2.0.1"
  spec.add_development_dependency "sbmt-kafka_producer", ">= 1.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "standard", ">= 1.35.1"
  spec.add_development_dependency "vcr", ">= 6.0"
  spec.add_development_dependency "faraday", "> 1.0"
  spec.add_development_dependency "webmock", ">= 3.0"
  spec.add_development_dependency "gruf-rspec", ">= 0.6.0"
end
