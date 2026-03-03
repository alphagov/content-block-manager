RSpec.describe BlockPreview::DynamicPreviewController, type: :request do
  include BlockPreview::Engine.routes.url_helpers

  let(:document) { build(:document, id: 1) }
  let(:edition) { build(:edition, id: 2, document_id: 1) }
  let(:block) { build(:content_block, id: 2) }
  let(:host_content_id) { "00000000-c9cf-0000-0000-000000000000" }
  let(:locale) { "en" }

  before do
    allow(Document).to receive(:find).and_return(document)
    allow(document).to receive(:latest_published_edition).and_return(edition)
    allow(ContentBlock).to receive(:from_edition_id).and_return(block)
  end

  describe "GET #show" do
    let(:path) do
      dynamic_host_content_preview_path(host_content_id: host_content_id,
                                        document_id: document.id,
                                        locale: locale)
    end

    include_examples "allows authentication with a JWT"
  end
end
