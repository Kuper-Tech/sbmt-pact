# frozen_string_literal: true

describe Sbmt::Pact::Provider::PactBrokerProxyRunner do
  let(:http_client) do
    Faraday.new do |conn|
      Sbmt::App::Http.configure_faraday(conn, name: "http-client")
      conn.response :json
      conn.request :json
    end
  end

  let(:broker_host) { "https://example.org" }
  let(:proxy_host) { server.proxy_url }
  let(:make_request) { server.run { http_client.get(request_url) } }

  context "with pact data request" do
    let(:request_url) { "#{proxy_host}/pacts/provider/paas-stand-seeker/consumer/paas-stand-placer/pact-version/2967a9343bd8fdd28a286c4b8322380020618892/metadata/c1tdW2VdPXByb2R1Y3Rpb24mc1tdW2N2XT03MzIy" }
    let(:server) { described_class.new(pact_broker_host: broker_host, filter_type: filter_type) }

    around do |example|
      VCR.use_cassette("pact-broker/pact_data") { example.run }
    end

    context "when filter_type matches" do
      let(:filter_type) { described_class::FILTER_TYPE_GRPC }

      it "replaces interaction descriptions" do
        response = make_request
        descriptions = response.body["interactions"].pluck("description")

        expect(response.status).to eq(200)
        expect(response.headers["content-length"]).to eq("9462")
        expect(descriptions).to eq(["grpc: ", "grpc: "])
      end
    end

    context "when filter_type does not match" do
      let(:filter_type) { described_class::FILTER_TYPE_HTTP }

      it "proxies original response" do
        response = make_request
        descriptions = response.body["interactions"].pluck("description")

        expect(response.status).to eq(200)
        expect(response.headers["content-length"]).to eq("9450")
        expect(descriptions).to eq(["", ""])
      end
    end
  end

  context "with other broker request" do
    let(:server) { described_class.new(pact_broker_host: broker_host, filter_type: described_class::FILTER_TYPE_GRPC) }
    let(:request_url) { "#{proxy_host}/pacts/provider/paas-stand-seeker/for-verification" }

    it "proxies without modification" do
      VCR.use_cassette "pact-broker/for_verification" do
        response = make_request
        expect(response.status).to eq(200)
        expect(response.headers["content-length"]).to eq("2997")
      end
    end
  end

  context "with broker error" do
    let(:server) { described_class.new(pact_broker_host: broker_host) }
    let(:request_url) { "#{proxy_host}/pacts/provider/non-existent-provider/for-verification" }

    it "proxies without modification" do
      VCR.use_cassette "pact-broker/not_found" do
        response = make_request
        expect(response.status).to eq(404)
        expect(response.body).to eq("error" => "No provider with name 'non-existent-provider' found")
      end
    end
  end
end
