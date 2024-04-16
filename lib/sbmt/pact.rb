# frozen_string_literal: true

require "zeitwerk"

module Sbmt
  module Pact
    class Error < StandardError; end
    # Your code goes here...
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, ".."))

loader.tag = "sbmt-pact"

loader.ignore("#{__dir__}/pact/version.rb")

loader.setup
loader.eager_load
