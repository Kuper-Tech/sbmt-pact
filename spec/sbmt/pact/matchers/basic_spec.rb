# frozen_string_literal: true

RSpec.describe Sbmt::Pact::Matchers::Basic do
  subject(:test_class) { Class.new { extend Sbmt::Pact::Matchers::Basic } }

  it "properly builds matcher for UUID" do
    expect(test_class.match_uuid.to_json).to eq("{\"pact:matcher:type\":\"regex\",\"value\":\"e1d01e04-3a2b-4eed-a4fb-54f5cd257338\",\"regex\":\"(?i-mx:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\"}")
  end

  it "properly builds matcher for regex" do
    expect(test_class.match_regex(/(A-Z){1,3}/, "ABC").to_json).to eq("{\"pact:matcher:type\":\"regex\",\"value\":\"ABC\",\"regex\":\"(?-mix:(A-Z){1,3})\"}")
  end

  it "properly builds matcher for datetime" do
    expect(test_class.match_datetime("yyyy-MM-dd HH:mm:ssZZZZZ", "2020-05-21 16:44:32+10:00").to_json).to eq("{\"pact:matcher:type\":\"datetime\",\"value\":\"2020-05-21 16:44:32+10:00\",\"format\":\"yyyy-MM-dd HH:mm:ssZZZZZ\"}")
  end

  it "properly builds matcher for date" do
    expect(test_class.match_date("yyyy-MM-dd", "2020-05-21").to_json).to eq("{\"pact:matcher:type\":\"date\",\"value\":\"2020-05-21\",\"format\":\"yyyy-MM-dd\"}")
  end

  it "properly builds matcher for time" do
    expect(test_class.match_time("HH:mm:ss", "16:44:32").to_json).to eq("{\"pact:matcher:type\":\"time\",\"value\":\"16:44:32\",\"format\":\"HH:mm:ss\"}")
  end

  it "properly builds matcher for include" do
    expect(test_class.match_include("some string").to_json).to eq("{\"pact:matcher:type\":\"include\",\"value\":\"some string\"}")
  end

  it "properly builds matcher for any string" do
    expect(test_class.match_any_string.to_json).to eq("{\"pact:matcher:type\":\"regex\",\"value\":\"any\",\"regex\":\"(?-mix:.*)\"}")
    expect(test_class.match_any_string("").to_json).to eq("{\"pact:matcher:type\":\"regex\",\"value\":\"\",\"regex\":\"(?-mix:.*)\"}")
  end

  it "properly builds matcher for boolean values" do
    expect(test_class.match_any_boolean.to_json).to eq("{\"pact:matcher:type\":\"boolean\",\"value\":true}")
  end

  it "properly builds matcher for integer values" do
    expect(test_class.match_any_integer.to_json).to eq("{\"pact:matcher:type\":\"integer\",\"value\":10}")
  end

  it "properly builds matcher for float values" do
    expect(test_class.match_any_decimal.to_json).to eq("{\"pact:matcher:type\":\"decimal\",\"value\":10.0}")
  end

  it "properly builds matcher for exact values" do
    expect(test_class.match_exactly("some arg").to_json).to eq("{\"pact:matcher:type\":\"equalTo\",\"value\":\"some arg\"}")
    expect(test_class.match_exactly(1).to_json).to eq("{\"pact:matcher:type\":\"equalTo\",\"value\":1}")
    expect(test_class.match_exactly(true).to_json).to eq("{\"pact:matcher:type\":\"equalTo\",\"value\":true}")
  end

  it "properly builds typed matcher" do
    expect(test_class.match_type_of(1).to_json).to eq("{\"pact:matcher:type\":\"type\",\"value\":1}")
    expect { test_class.match_type_of(Object.new).to_json }.to raise_error(/is not a primitive/)
  end
end
