# frozen_string_literal: true

source "https://nexus.sbmt.io/repository/rubygems/"

gemspec

source "https://nexus.sbmt.io/repository/ruby-gems-sbermarket/" do
  gem "pact-ffi"

  group :development, :test do
    gem "sbmt-app"
    gem "sbmt-dev"
  end
end

group :development, :test do
  # https://jira.sbmt.io/browse/DEX-2404
  gem "sidekiq", "< 7.3.0"
end
