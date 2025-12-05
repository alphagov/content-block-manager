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
      allow(edition).to receive(:set_auth_bypass_id)
      allow(edition).to receive(:save!)
    end

    it "updates the edition and redirects to the document path" do
      put update_fact_check_preview_link_edition_path(edition)

      expect(response).to redirect_to(document_path(document))

      expect(flash[:notice]).to eq("New preview link generated")
      expect(edition).to have_received(:set_auth_bypass_id)
      expect(edition).to have_received(:save!)
    end

    context "when the request is made as a turbo stream" do
      it "renders a template" do
        put update_fact_check_preview_link_edition_path(edition, format: :turbo_stream)

        expect(response).to render_template("editions/fact_check_preview_link/show")

        expect(edition).to have_received(:set_auth_bypass_id)
        expect(edition).to have_received(:save!)
      end
    end
  end
end
