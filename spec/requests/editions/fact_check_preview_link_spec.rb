RSpec.describe Editions::FactCheckPreviewLinkController, type: :request do
  include Rails.application.routes.url_helpers

  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "#update" do
    let(:document) { build_stubbed(:document, content_id_alias: "content-id-alias") }
    let(:edition) { build_stubbed(:edition, document:) }

    before do
      allow(Edition).to receive(:find).with(edition.id.to_s).and_return(edition)
    end

    it "updates the edition and redirects to the document path" do
      allow(edition).to receive(:set_auth_bypass_id)
      allow(edition).to receive(:save!)

      put update_fact_check_preview_link_edition_path(edition)

      expect(response).to redirect_to(document_path(document))

      expect(flash[:notice]).to eq("New preview link generated")
      expect(edition).to have_received(:set_auth_bypass_id)
      expect(edition).to have_received(:save!)
    end
  end
end
