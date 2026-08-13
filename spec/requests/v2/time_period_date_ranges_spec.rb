RSpec.describe "V2::TimePeriodDateRanges", type: :request do
  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "PATCH /v2/documents/:document_id/time-period-date-ranges/:id" do
    let(:edition) do
      create(:v2_time_period_edition, title: "Old Title", description: "Old")
    end
    let(:document) { edition.document }

    let(:valid_date_range_attributes) do
      {
        edition: {
          date_range_attributes: {
            start: "2025-04-06 09:00",
            end: "2026-04-05 17:30",
          },
        },
      }
    end

    let(:invalid_date_range_attributes) do
      {
        edition: {
          date_range_attributes: {
            start: "2026-04-06 09:00",
            end: "2025-04-05 17:30", # End before start
          },
        },
      }
    end

    context "with valid parameters" do
      it "updates the date range" do
        patch v2_document_time_period_date_range_path(document, edition),
              params: valid_date_range_attributes
        edition.reload
        expect(edition.date_range.start).to eq(
          Time.zone.parse("2025-04-06 09:00"),
        )
        expect(edition.date_range.end).to eq(
          Time.zone.parse("2026-04-05 17:30"),
        )
      end

      it "redirects to the edition with a success message" do
        patch v2_document_time_period_date_range_path(document, edition),
              params: valid_date_range_attributes
        expect(response).to redirect_to(
          v2_time_period_edition_path(edition),
        )
        expect(flash[:notice]).to eq(I18n.t("v2/time_period_edition.create.success"))
      end
    end

    context "with invalid parameters" do
      it "does not update the edition" do
        original_start = edition.date_range&.start
        patch v2_document_time_period_date_range_path(document, edition),
              params: invalid_date_range_attributes
        edition.reload
        expect(edition.date_range&.start).to eq(original_start)
      end

      it "returns unprocessable entity status" do
        patch v2_document_time_period_date_range_path(document, edition),
              params: invalid_date_range_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch v2_document_time_period_date_range_path(document, edition),
              params: invalid_date_range_attributes
        expect(response).to render_template(:edit)
      end
    end
  end
end
