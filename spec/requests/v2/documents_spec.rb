RSpec.describe "V2 documents", type: :request do
  before do
    logout
    login_as(create(:user))
  end

  describe "GET /v2/documents" do
    let(:organisation) { build(:organisation) }

    before do
      allow(Organisation).to receive(:all).and_return([organisation])
    end

    it "renders the index page with listed documents sorted by most recently created edition" do
      document_with_older_edition = create(:v2_document)
      create(
        :v2_time_period_edition,
        document: document_with_older_edition,
        title: "Tax Year 2025",
        lead_organisation_id: organisation.id,
        created_at: 1.year.ago,
      )

      document_with_newer_edition = create(:v2_document)
      create(
        :v2_time_period_edition,
        document: document_with_newer_edition,
        title: "British Summer Time 2026",
        lead_organisation_id: organisation.id,
        created_at: 1.day.ago,
      )

      get v2_documents_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template("v2/documents/index")

      expect(page).to have_css("[data-testid='homepage-item-0']", text: "British Summer Time 2026")
      expect(page).to have_css("[data-testid='homepage-item-1']", text: "Tax Year 2025")
    end
  end
end
