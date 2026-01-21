RSpec.describe BlockPreview::PreviewController, type: :controller do
  describe "GET #show" do
    routes { BlockPreview::Engine.routes }

    let(:edition_id) { "123" }
    let(:host_content_id) { "content-id-abc" }
    let(:base_path) { "/government/base-path" }
    let(:locale) { "en" }

    let(:mock_block) { instance_double("ContentBlock") }
    let(:mock_preview_content) { instance_double(BlockPreview::PreviewContent) }

    before do
      allow(ContentBlock).to receive(:from_edition_id).and_return(mock_block)
      allow(BlockPreview::PreviewContent).to receive(:new).and_return(mock_preview_content)

      get :show, params: {
        edition_id: edition_id,
        host_content_id: host_content_id,
        base_path: base_path,
        locale: locale,
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "finds the content block using the edition_id param" do
      expect(ContentBlock).to have_received(:from_edition_id).with(edition_id)
    end

    it "initializes the preview content service with the correct params" do
      expect(BlockPreview::PreviewContent).to have_received(:new).with(
        content_id: host_content_id,
        block: mock_block,
        base_path: base_path,
        locale: locale,
      )
    end

    it "assigns the @block instance variable" do
      expect(assigns(:block)).to eq(mock_block)
    end

    it "assigns the @preview_content instance variable" do
      expect(assigns(:preview_content)).to eq(mock_preview_content)
    end
  end
end
