# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

# Engine root is used by rails_configuration to correctly
# load fixtures and support files
require "pathname"
ENGINE_ROOT = Pathname.new(File.expand_path("..", __dir__))

require "webmock"
require "vcr"
require "faraday"
require "gruf"
require "gruf/rspec"
require "yabeda" # we have to require it becase of this https://github.com/yabeda-rb/yabeda/pull/38

require "combustion"

begin
  Combustion.initialize! :action_controller do
    config.log_level = :fatal if ENV["LOG"].to_s.empty?
    config.i18n.available_locales = %i[ru en]
    config.i18n.default_locale = :ru
  end
rescue => e
  # Fail fast if application couldn't be loaded
  warn "💥 Failed to load the app: #{e.message}\n#{e.backtrace.join("\n")}"
  exit(1)
end

require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!

Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Optional dependencies
require "sbmt/kafka_consumer"
require "sbmt/kafka_producer"
