RSpec.describe BlockPreview::FormSubmission do
  let(:body) { { field: "value", another_field: "data" } }
  let(:method) { "post" }

  let(:website_host) { URI.parse(Plek.website_root).host }
  let(:draft_host) { URI.parse(Plek.external_url_for("draft-origin")).host }

  describe "#initialize" do
    context "with an allowed frontend host" do
      it "accepts the live frontend host" do
        url = "http://#{website_host}/form"
        service = described_class.new(url: url, body: body, method:)
        expect(service).to be_a(BlockPreview::FormSubmission)
      end

      it "accepts the draft frontend host" do
        url = "http://#{draft_host}/form"
        service = described_class.new(url: url, body: body, method:)
        expect(service).to be_a(BlockPreview::FormSubmission)
      end

      it "accepts paths with query parameters" do
        url = "http://#{website_host}/form?param=value"
        service = described_class.new(url: url, body: body, method:)
        expect(service).to be_a(BlockPreview::FormSubmission)
      end
    end

    context "with a disallowed host" do
      it "rejects arbitrary external domains" do
        expect {
          described_class.new(
            url: "https://evil.com/form", body: body, method:,
          )
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end

      it "rejects other gov.uk subdomains not in the allowlist" do
        expect {
          described_class.new(
            url: "https://other-service.gov.uk/form",
            body: body, method:
          )
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end

      it "rejects hosts that merely contain an allowed host" do
        expect {
          described_class.new(
            url: "https://#{website_host}.evil.com/form",
            body: body, method:
          )
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end

      it "rejects URLs without a host" do
        expect {
          described_class.new(url: "form", body: body, method:)
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end
    end
  end

  describe "#redirect_path" do
    let(:valid_url) { "http://#{website_host}/form" }
    let(:service) { described_class.new(url: valid_url, body: body, method:) }
    let(:redirect_location) { "https://#{website_host}/preview/123" }

    before do
      stub_request(:post, valid_url)
        .with(body: body)
        .to_return(
          status: response_code,
          headers: {
            "location" => redirect_location,
          },
        )
    end

    context "when response is a 302 redirect" do
      let(:response_code) { 302 }

      it "returns the path of the redirect location" do
        expect(service.redirect_path).to eq("/preview/123")
      end

      context "when the method is get" do
        let(:method) { "get" }

        before do
          stub_request(:get, "#{valid_url}?#{body.to_query}")
            .to_return(
              status: response_code,
              headers: {
                "location" => redirect_location,
              },
            )
        end

        it "returns the path of the redirect location" do
          expect(service.redirect_path).to eq("/preview/123")
        end
      end
    end

    context "when response has a redirect with query parameters" do
      let(:redirect_location) do
        "https://#{website_host}/preview/123?param=value"
      end
      let(:response_code) { 302 }

      it "includes query parameters in the returned path" do
        expect(service.redirect_path).to eq("/preview/123?param=value")
      end
    end

    context "when response has a non-http(s) location" do
      let(:redirect_location) { "/preview" }
      let(:response_code) { 302 }

      it "raises UnexpectedResponseError" do
        expect {
          service.redirect_path
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedResponseError)
      end
    end

    context "when response is not a 302" do
      let(:response_code) { 200 }

      it "raises UnexpectedResponseError" do
        expect {
          service.redirect_path
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedResponseError)
      end
    end

    context "when response is a 301 redirect" do
      let(:response_code) { 301 }

      it "raises UnexpectedResponseError" do
        expect {
          service.redirect_path
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedResponseError)
      end
    end

    context "when response is a 404" do
      let(:response_code) { 404 }

      it "raises UnexpectedResponseError" do
        expect {
          service.redirect_path
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedResponseError)
      end
    end
  end

  describe ".allowed_hosts" do
    it "includes the live frontend host" do
      expect(described_class.allowed_hosts).to include(website_host)
    end

    it "includes the draft frontend host" do
      expect(described_class.allowed_hosts).to include(draft_host)
    end

    it "does not include arbitrary hosts" do
      expect(described_class.allowed_hosts).not_to include("evil.com")
    end
  end
end
