# frozen_string_literal: true

RSpec.describe Sbmt::Pact::Matchers do
  subject(:test_class) { Class.new { extend Sbmt::Pact::Matchers } }

  it "properly builds matcher for UUID" do
    expect(test_class.match_uuid).to eq("matching(regex, '(?i-mx:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', 'e1d01e04-3a2b-4eed-a4fb-54f5cd257338')")
  end

  it "properly builds matcher for regex" do
    expect(test_class.match_regex(/(A-Z){1,3}/, "ABC")).to eq("matching(regex, '(?-mix:(A-Z){1,3})', 'ABC')")
  end

  it "properly builds matcher for datetime" do
    expect(test_class.match_datetime("yyyy-MM-dd HH:mm:ssZZZZZ", "2020-05-21 16:44:32+10:00")).to eq("matching(datetime, 'yyyy-MM-dd HH:mm:ssZZZZZ', '2020-05-21 16:44:32+10:00')")
  end

  it "properly builds matcher for date" do
    expect(test_class.match_date("yyyy-MM-dd", "2020-05-21")).to eq("matching(datetime, 'yyyy-MM-dd', '2020-05-21')")
  end

  it "properly builds matcher for time" do
    expect(test_class.match_time("HH:mm:ss", "16:44:32")).to eq("matching(datetime, 'HH:mm:ss', '16:44:32')")
  end

  it "properly builds matcher for include" do
    expect(test_class.match_include("some string")).to eq("matching(include, 'some string')")
  end

  it "properly builds matcher for any string" do
    expect(test_class.match_any_string).to eq("matching(regex, '(?-mix:.+)', 'any')")
  end

  it "properly builds matcher for boolean values" do
    expect(test_class.match_any_boolean).to eq("matching(boolean, true)")
  end

  it "properly builds matcher for integer values" do
    expect(test_class.match_any_integer).to eq("matching(integer, 10)")
  end

  it "properly builds matcher for float values" do
    expect(test_class.match_any_decimal).to eq("matching(decimal, 10.0)")
  end

  it "properly builds matcher for exact values" do
    expect(test_class.match_exactly("some arg")).to eq("matching(equalTo, 'some arg')")
    expect(test_class.match_exactly(1)).to eq("matching(equalTo, 1)")
    expect(test_class.match_exactly(true)).to eq("matching(equalTo, true)")
  end

  it "properly builds typed matcher" do
    expect(test_class.match_type_of(1)).to eq("matching(type, 1)")
    expect { test_class.match_type_of(Object.new) }.to raise_error(/is not a primitive/)
  end
end
