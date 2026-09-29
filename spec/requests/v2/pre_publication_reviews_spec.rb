RSpec.describe "V2::PrePublicationReviews", type: :request do
  let(:organisation) { build(:organisation, id: SecureRandom.uuid) }
  let(:document) { create(:v2_document, block_type: "time_period") }
  let(:edition) { create(:v2_time_period_edition, document: document, state: "draft", lead_organisation_id: organisation.id) }
  let!(:date_range) { create(:v2_time_period_date_range, edition: edition) }

  before do
    logout
    login_as(create(:user))
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  let(:request_url) { "/v2/time_period_editions/#{edition.id}/review" }

  describe "GET /v2/time_period_editions/8/review" do
    context "when the edition exists and is valid" do
      before { get request_url }

      it "renders the review page" do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("v2/pre_publication_reviews/new")
      end

      it "renders the correct page title from the helper method" do
        expect(response.body).to include("Review time period")
      end
    end

    context "when the edition does not exist" do
      let(:request_url) { "/v2/time_period_editions/invalid_id/review" }

      it "responds with a 404 Not Found" do
        get request_url
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
