# frozen_string_literal: true

require "zeitwerk"
require "pact/ffi"

require "sbmt/pact/railtie" if defined?(Rails::Railtie)

module Sbmt
  module Pact
    class Error < StandardError; end

    class FfiError < Error
      def initialize(msg, reason, status)
        super(msg)

        @msg = msg
        @reason = reason
        @status = status
      end

      def message
        "FFI error: reason: #{@reason}, status: #{@status}, message: #{@msg}"
      end
    end

    def self.configure
      yield configuration if block_given?
    end

    def self.configuration
      @configuration ||= Sbmt::Pact::Configuration.new
    end
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, ".."))

loader.tag = "sbmt-pact"

loader.ignore("#{__dir__}/pact/version.rb")
loader.ignore("#{__dir__}/pact/rspec.rb")
loader.ignore("#{__dir__}/pact/rspec")

loader.setup
loader.eager_load
