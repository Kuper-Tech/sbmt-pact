# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:pact).tap do |task|
  task.rspec_opts = "--require rails_helper --tag type:pact"
end

namespace :pact do
  desc "Verifies the pact files"
  task verify: :pact
end
