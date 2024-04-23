# frozen_string_literal: true

RSpec.configure do |config|
  config.include Sbmt::Pact::Matchers, type: :pact
end
