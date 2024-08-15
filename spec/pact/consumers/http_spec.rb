# frozen_string_literal: true

require "sbmt/pact/rspec"

RSpec.describe "Sbmt::Pact::Consumers::Http", :pact do
  http_pact_provider "sbmt-pact-test-app"
end
