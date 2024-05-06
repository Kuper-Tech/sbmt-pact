# frozen_string_literal: true

require "rails/railtie"

module Sbmt
  module Pact
    class Railtie < Rails::Railtie
      rake_tasks do
        load "sbmt/pact/tasks/pact.rake"
      end
    end
  end
end
