RSpec.describe BlockPreview::FormSubmission do
  let(:valid_url) { "https://example.gov.uk/form" }
  let(:body) { { field: "value", another_field: "data" } }
  let(:method) { "post" }

  describe "#initialize" do
    context "with a valid gov.uk URL" do
      it "successfully creates an instance" do
        service = described_class.new(url: valid_url, body: body, method:)
        expect(service).to be_a(BlockPreview::FormSubmission)
      end
    end

    context "with a subdomain of gov.uk" do
      it "accepts the URL" do
        url = "https://subdomain.example.gov.uk/path"
        service = described_class.new(url: url, body: body, method:)
        expect(service).to be_a(BlockPreview::FormSubmission)
      end
    end

    context "with an invalid URL" do
      it "raises UnexpectedUrlError for non-gov.uk domains" do
        invalid_url = "https://example.com/form"
        expect {
          described_class.new(url: invalid_url, body: body, method:)
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end

      it "raises UnexpectedUrlError for URLs that contain but don't end with gov.uk" do
        invalid_url = "https://gov.uk.fake.com/form"
        expect {
          described_class.new(url: invalid_url, body: body, method:)
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end
    end

    context "with a URL without a domain" do
      it "raises UnexpectedUrlError domains" do
        invalid_url = "form"
        expect {
          described_class.new(url: invalid_url, body: body, method:)
        }.to raise_error(BlockPreview::FormSubmission::UnexpectedUrlError)
      end
    end
  end

  describe "#redirect_path" do
    let(:service) { described_class.new(url: valid_url, body: body, method:) }
    let(:response) { double(code: response_code, headers: { "location" => redirect_location }) }

    let(:redirect_location) { "https://example.gov.uk/preview/123" }

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
      let(:redirect_location) { "https://example.gov.uk/preview/123?param=value" }
      let(:response_code) { 302 }

      it "returns only the path without query parameters" do
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
end
