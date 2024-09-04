# frozen_string_literal: true

source ENV.fetch("RUBYGEMS_PUBLIC_SOURCE", "https://rubygems.org/")

gemspec

source ENV.fetch("RUBYGEMS_PRIVATE_SOURCE", "https://nexus.sbmt.io/repository/ruby-gems-sbermarket/") do
  group :development, :test do
    gem "sbmt-app"
  end
end
