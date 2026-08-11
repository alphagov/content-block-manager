RSpec.describe "V2 documents", type: :request do
  before do
    logout
    login_as(create(:user))
  end

  describe "GET /v2/documents" do
    let(:organisation) { build(:organisation, id: SecureRandom.uuid) }

    before do
      allow(Organisation).to receive(:all).and_return([organisation])
    end

    context "when no filters are provided in the params" do
      it "redirects to the index path with default filters" do
        get v2_documents_path

        expect(response).to redirect_to(v2_documents_path(lead_organisation: ""))
      end
    end

    context "when valid filters are provided" do
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

        get v2_documents_path, params: { lead_organisation: "" }

        expect(response).to have_http_status(:success)
        expect(response).to render_template("v2/documents/index")

        expect(page).to have_css("[data-testid='homepage-item-0']", text: "British Summer Time 2026")
        expect(page).to have_css("[data-testid='homepage-item-1']", text: "Tax Year 2025")
      end
    end

    context "when the DocumentFilter raises an error" do
      it "rescues the error, assigns error messages, and renders the index" do
        date_error = V2::Document::DocumentFilter::FILTER_ERROR.new(
          attribute: "last_updated_from_3i",
          full_message: "Last updated from date is invalid",
        )
        filter_error = V2::Document::DocumentFilter::InvalidFiltersError.new([date_error])

        filter = double("DocumentFilter")
        allow(V2::Document::DocumentFilter).to receive(:new).and_return(filter)

        expect(filter).to receive(:call).ordered.and_raise(filter_error)
        expect(filter).to receive(:call).ordered.and_return(V2::Document.none.page(1))

        get v2_documents_path, params: {
          last_updated_from: { "1i" => "2026", "2i" => "13", "3i" => "44" },
        }

        expect(response).to have_http_status(:success)
        expect(response).to render_template("v2/documents/index")

        expect(assigns(:errors)).to eq([date_error])
        expect(assigns(:error_summary_errors)).to eq([
          { text: "Last updated from date is invalid", href: "#last_updated_from_3i" },
        ])
      end
    end
  end
end
