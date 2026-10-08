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

  describe "POST /v2/time_period_editions/8/review" do
    context "when the confirmation checkbox is checked" do
      let(:valid_params) { { edition: { has_checked_content: "1" } } }

      context "when publishing is successful" do
        it "updates the state and redirects with a success notice" do
          post v2_time_period_edition_review_path(time_period_edition_id: edition.id), params: valid_params

          expect(edition.reload).to be_published
          expect(response).to redirect_to(v2_documents_path)
          expect(flash[:notice]).to eq(I18n.t("v2.edition.publish.success"))
        end
      end

      context "when publishing fails" do
        before do
          allow_any_instance_of(V2::Edition).to receive(:update).and_return(false)
        end

        it "does not update the state and re-renders the review page" do
          post v2_time_period_edition_review_path(time_period_edition_id: edition.id), params: valid_params

          expect(edition.reload).to be_draft
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template("v2/pre_publication_reviews/new")
        end
      end
    end

    context "when the confirmation checkbox is NOT checked" do
      it "does not publish the edition and re-renders with a validation error" do
        post v2_time_period_edition_review_path(time_period_edition_id: edition.id)

        expect(edition.reload).to be_draft
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template("v2/pre_publication_reviews/new")

        expect(response.body).to include("There is a problem")
        expect(response.body).to include(
          I18n.t("v2.edition.pre_publication_review.errors.confirm"),
        )
      end
    end
  end
end
