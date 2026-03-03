RSpec.describe BlockPreview::DynamicPreviewController, type: :request do
  include BlockPreview::Engine.routes.url_helpers

  let(:mock_preview_content) do
    instance_double(BlockPreview::PreviewContent, title: "Test", html: "<p>Test</p>", instances_count: 2)
  end
  let(:document) { build(:document, id: 1) }
  let(:edition) { build(:edition, id: 2, document_id: 1) }
  let(:block) { build(:content_block, id: 2) }
  let(:host_content_id) { "00000000-c9cf-0000-0000-000000000000" }
  let(:locale) { "en" }

  before do
    allow(Document).to receive(:find).and_return(document)
    allow(document).to receive(:latest_published_edition).and_return(edition)
    allow(document).to receive(:most_recent_edition).and_return(edition)
    allow(ContentBlock).to receive(:from_edition_id).and_return(block)
    allow(BlockPreview::PreviewContent).to receive(:new).and_return(mock_preview_content)
  end

  describe "GET #show" do
    let(:path) do
      dynamic_host_content_preview_path(host_content_id: host_content_id,
                                        document_id: document.id,
                                        locale: locale)
    end

    include_examples "allows authentication with a JWT"

    describe "when viewing the preview" do
      let(:user) { create(:user) }

      before do
        login_as(user)
        expect(BlockPreview::PreviewContent).to receive(:new).and_return(mock_preview_content)
        get path
      end

      it "should render the content of the published host document" do
        expect(response.body).to include("<p>Test</p>")
      end
    end
  end
end
