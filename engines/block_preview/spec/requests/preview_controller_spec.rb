RSpec.describe BlockPreview::PreviewController, type: :request do
  include BlockPreview::Engine.routes.url_helpers

  let(:block) { build(:content_block, id: "123") }
  let(:mock_preview_content) { instance_double(BlockPreview::PreviewContent, title: "Test", html: "<p>Test</p>", instances_count: 2) }

  let(:edition_id) { "123" }
  let(:host_content_id) { "content-id-abc" }
  let(:base_path) { "/government/base-path" }
  let(:locale) { "en" }

  before do
    allow(ContentBlock).to receive(:from_edition_id).and_return(block)
    allow(BlockPreview::PreviewContent).to receive(:new).and_return(mock_preview_content)
  end

  describe "GET #show" do
    let(:path) do
      host_content_preview_path(edition_id: edition_id,
                                host_content_id: host_content_id,
                                base_path: base_path,
                                locale: locale)
    end

    include_examples "allows authentication with a JWT"
  end

  describe "POST #form_handler" do
    let(:url) { "https://example.gov.uk/form" }
    let(:http_method) { "post" }
    let(:body_params) { { "field_name" => "field_value" } }

    let(:mock_submission) { instance_double(BlockPreview::FormSubmission) }
    let(:redirect_path_result) { "/" }

    let(:path) do
      host_content_preview_form_handler_path(edition_id: edition_id,
                                             host_content_id: host_content_id,
                                             locale: locale)
    end

    let(:params) do
      {
        url: url,
        method: http_method,
        body: body_params,
      }
    end

    before do
      ENV["JWT_AUTH_SECRET"] = "secret"

      allow(BlockPreview::FormSubmission).to receive(:new).and_return(mock_submission)
      allow(mock_submission).to receive(:redirect_path).and_return(redirect_path_result)
    end

    let(:valid_token) do
      JWT.encode(
        { sub: block.auth_bypass_id },
        ENV["JWT_AUTH_SECRET"],
        "HS256",
      )
    end

    around do |test|
      # Disable GDS SSO mocking for these tests
      ClimateControl.modify("GDS_SSO_MOCK_INVALID" => "1") do
        test.call
      end
    end

    it "prompts for authentication when no token is provided" do
      post path, params: params

      expect(response).to redirect_to("/auth/gds")
    end

    it "does not prompt for authentication when a valid token is provided" do
      post path, params: params.merge(token: valid_token)

      expect(response).to_not redirect_to("/auth/gds")
    end

    it "does not prompt for authentication when a valid token is present in the cookies" do
      # Make a request to host_content_preview_path to set the cookie
      get host_content_preview_path(edition_id: edition_id,
                                    host_content_id: host_content_id,
                                    base_path: base_path,
                                    locale: locale,
                                    token: valid_token)

      post path, params: params

      expect(response).to_not redirect_to("/auth/gds")
    end
  end
end
