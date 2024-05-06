# frozen_string_literal: true

RSpec.describe Sbmt::Pact::Matchers do
  subject(:test_class) { Class.new { extend Sbmt::Pact::Matchers } }

  it "properly builds matcher for UUID" do
    expect(test_class.pact_match_uuid).to eq("matching(regex, '(?i-mx:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', 'e1d01e04-3a2b-4eed-a4fb-54f5cd257338')")
  end

  it "properly builds matcher for include" do
    expect(test_class.pact_match_include("some string")).to eq("matching(include, 'some string')")
  end

  it "properly builds matcher for any string" do
    expect(test_class.pact_match_any_string).to eq("matching(regex, '(?-mix:.+)', 'any')")
  end

  it "properly builds matcher for boolean values" do
    expect(test_class.pact_match(true)).to eq("matching(boolean, true)")
  end

  it "properly builds matcher for integer values" do
    expect(test_class.pact_match(1)).to eq("matching(integer, 1)")
  end

  it "properly builds matcher for float values" do
    expect(test_class.pact_match(1.0)).to eq("matching(decimal, 1.0)")
  end

  it "properly builds matcher for string values" do
    expect(test_class.pact_match("some arg")).to eq("matching(equalTo, 'some arg')")
  end

  it "raises error if matcher type is not supported" do
    expect { test_class.pact_match(Object.new) }.to raise_error(/is not supported yet/)
  end
end
