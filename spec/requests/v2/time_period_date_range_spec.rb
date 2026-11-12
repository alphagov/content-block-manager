RSpec.describe "V2::TimePeriodDateRange", type: :request do
  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "GET /v2/documents/:document_id/editions/:edition_id/date_range/edit" do
    context "with no previous existing time period edition" do
      let(:edition) { create(:v2_time_period_edition) }

      before do
        get edit_v2_document_edition_date_range_path(edition.document, edition)
      end

      it "renders the edit view successfully" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("v2/time_period_date_ranges/edit")
      end

      it "will not pre-populate the date range form" do
        expect(assigns(:edition).date_range.start).to be_nil
        expect(assigns(:edition).date_range.end).to be_nil

        expect(page).to have_css("form[action='#{v2_document_edition_date_range_path(edition.document, edition)}']") do |form|
          expect(form).to have_select("edition[date_range_attributes][start(5i)]", selected: nil)
          expect(form).to have_select("edition[date_range_attributes][start(4i)]", selected: nil)
          expect(form.find_field("edition[date_range_attributes][start(3i)]").value).to be_blank
          expect(form.find_field("edition[date_range_attributes][start(2i)]").value).to be_blank
          expect(form.find_field("edition[date_range_attributes][start(1i)]").value).to be_blank

          expect(form).to have_select("edition[date_range_attributes][end(5i)]", selected: nil)
          expect(form).to have_select("edition[date_range_attributes][end(4i)]", selected: nil)
          expect(form.find_field("edition[date_range_attributes][end(3i)]").value).to be_blank
          expect(form.find_field("edition[date_range_attributes][end(2i)]").value).to be_blank
          expect(form.find_field("edition[date_range_attributes][end(1i)]").value).to be_blank
        end
      end
    end

    context "with previous existing time period edition" do
      let(:old_edition) { create(:v2_time_period_edition, state: "published") }
      let(:new_edition) { create(:v2_time_period_edition, document: old_edition.document) }
      let!(:date_range) { FactoryBot.create(:v2_time_period_date_range, edition: old_edition) }

      before do
        old_edition.reload

        get edit_v2_document_edition_date_range_path(new_edition.document, new_edition)
      end

      it "renders the edit view successfully" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("v2/time_period_date_ranges/edit")
      end

      it "will pre-populate the date range form using the existing edition's details" do
        expect(assigns(:edition).date_range.id).not_to eq(old_edition.date_range.id)
        expect(assigns(:edition).date_range.start).to eq(old_edition.date_range.start)
        expect(assigns(:edition).date_range.end).to eq(old_edition.date_range.end)

        expect(page).to have_css("form[action='#{v2_document_edition_date_range_path(new_edition.document, new_edition)}']") do |form|
          expect(form).to have_select("edition[date_range_attributes][start(5i)]", selected: sprintf("%02d", date_range.start.min))
          expect(form).to have_select("edition[date_range_attributes][start(4i)]", selected: sprintf("%02d", date_range.start.hour))
          expect(form).to have_field("edition[date_range_attributes][start(3i)]", with: date_range.start.day)
          expect(form).to have_field("edition[date_range_attributes][start(2i)]", with: date_range.start.month)
          expect(form).to have_field("edition[date_range_attributes][start(1i)]", with: date_range.start.year)

          expect(form).to have_select("edition[date_range_attributes][end(5i)]", selected: sprintf("%02d", date_range.end.min))
          expect(form).to have_select("edition[date_range_attributes][end(4i)]", selected: sprintf("%02d", date_range.end.hour))
          expect(form).to have_field("edition[date_range_attributes][end(3i)]", with: date_range.end.day)
          expect(form).to have_field("edition[date_range_attributes][end(2i)]", with: date_range.end.month)
          expect(form).to have_field("edition[date_range_attributes][end(1i)]", with: date_range.end.year)
        end
      end
    end
  end

  describe "PATCH /v2/documents/:document_id/editions/:id/date-range" do
    let(:edition) do
      create(:v2_time_period_edition, title: "Old Title", description: "Old")
    end
    let(:document) { edition.document }

    let(:start_date) { "2025-04-06 09:00" }
    let(:end_date) { "2026-04-05 17:30" }

    let(:valid_date_range_attributes) do
      {
        edition: {
          date_range_attributes: {
            start: start_date,
            end: end_date,
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
      context "when there is no existing date range associated with the edition" do
        it "creates and associates the date range with the edition" do
          patch v2_document_edition_date_range_path(document, edition),
                params: valid_date_range_attributes

          edition.reload
          expect(edition.date_range).to be_present
          expect(edition.date_range.start).to eq(Time.zone.parse(start_date))
          expect(edition.date_range.end).to eq(Time.zone.parse(end_date))
        end

        it "redirects to the review path with the creation success message" do
          patch v2_document_edition_date_range_path(document, edition),
                params: valid_date_range_attributes

          expect(response).to redirect_to(new_v2_document_edition_pre_publication_review_path(document, edition))
          expect(flash[:success]).to eq(I18n.t("v2.time_period_edition.create.success"))
        end
      end

      context "when there is an existing date range associated with the edition" do
        let!(:existing_date_range) do
          create(
            :v2_time_period_date_range,
            edition: edition,
            start: start_date,
            end: end_date,
          )
        end

        let(:updated_start_date) { "2025-04-06 09:00" }
        let(:updated_end_date) { "2026-04-05 17:30" }

        let(:update_params) do
          {
            edition: {
              date_range_attributes: {
                id: existing_date_range.id,
                start: updated_start_date,
                end: updated_end_date,
              },
            },
          }
        end

        it "updates the existing date range in place" do
          expect {
            patch v2_document_edition_date_range_path(document, edition),
                  params: update_params
          }.not_to change(existing_date_range.class, :count)

          existing_date_range.reload
          expect(existing_date_range.start).to eq(Time.zone.parse(updated_start_date))
          expect(existing_date_range.end).to eq(Time.zone.parse(updated_end_date))
        end

        it "redirects to the review path with the update success message" do
          patch v2_document_edition_date_range_path(document, edition),
                params: update_params

          expect(response).to redirect_to(new_v2_document_edition_pre_publication_review_path(document, edition))
          expect(flash[:success]).to eq(I18n.t("v2.time_period_edition.update.success"))
        end
      end
    end

    context "with invalid parameters" do
      it "does not update the edition" do
        original_start = edition.date_range&.start
        patch v2_document_edition_date_range_path(document, edition),
              params: invalid_date_range_attributes
        edition.reload
        expect(edition.date_range&.start).to eq(original_start)
      end

      it "returns unprocessable content status" do
        patch v2_document_edition_date_range_path(document, edition),
              params: invalid_date_range_attributes
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders the edit template" do
        patch v2_document_edition_date_range_path(document, edition),
              params: invalid_date_range_attributes
        expect(response).to render_template(:edit)
      end
    end
  end
end
