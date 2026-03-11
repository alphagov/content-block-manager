RSpec.describe Shared::EmbeddedObject::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "when the embedded object has nested fields, as within TimePeriod#date_range" do
    let(:details) do
      {
        "date_range" => {
          "start" => { "date" => "2025-04-06", "time" => "00:00" },
          "end" => { "date" => "2026-04-05", "time" => "23:59" },
        },
      }
    end

    let(:document) { build(:document, :time_period) }
    let(:edition) { build_stubbed(:edition, :time_period, details:, document:) }

    let(:component) { described_class.new(edition:, object_type: "date_range") }

    before do
      %w[
        date_range/start/date
        date_range/start/time
        date_range/end/date
        date_range/end/time
      ].each do |field_path|
        allow(edition).to receive(:render)
          .with(edition.document.embed_code_for_field(field_path))
          .and_return("FORMATTED_DATE_OR_TIME")
      end
    end

    it "renders a summary card for each of the nested fields, with formatted dates and times" do
      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Date range details"

      expect(page).to have_css ".gem-c-summary-card[title='Start']" do
        expect(page).to have_css ".govuk-summary-list__row[data-testid='date']" do
          expect(page).to have_css ".govuk-summary-list__key", text: "Date"
          expect(page).to have_css ".govuk-summary-list__value", text: "FORMATTED_DATE_OR_TIME"
        end

        expect(page).to have_css ".govuk-summary-list__row[data-testid='time']" do
          expect(page).to have_css ".govuk-summary-list__key", text: "Time"
          expect(page).to have_css ".govuk-summary-list__value", text: "FORMATTED_DATE_OR_TIME"
        end
      end

      expect(page).to have_css ".gem-c-summary-card[title='End']" do
        expect(page).to have_css ".govuk-summary-list__row[data-testid='date']" do
          expect(page).to have_css ".govuk-summary-list__key", text: "Date"
          expect(page).to have_css ".govuk-summary-list__value", text: "FORMATTED_DATE_OR_TIME"
        end

        expect(page).to have_css ".govuk-summary-list__row[data-testid='time']" do
          expect(page).to have_css ".govuk-summary-list__key", text: "Time"
          expect(page).to have_css ".govuk-summary-list__value", text: "FORMATTED_DATE_OR_TIME"
        end
      end
    end

    it "includes a single 'Edit' link to edit the whole object" do
      render_inline component

      expected_edit_path = edit_sole_embedded_object_edition_path(
        edition,
        object_type: "date_range",
      )

      expect(page).to have_css ".govuk-summary-card__title-wrapper" do |title|
        expect(title).to have_css ".govuk-summary-card__action" do |action|
          expect(action).to have_css(
            "a[href='#{expected_edit_path}']",
            text: "Edit Date range details",
          )
        end
      end
    end
  end
end
