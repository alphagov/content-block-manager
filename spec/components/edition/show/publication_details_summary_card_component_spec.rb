RSpec.describe Edition::Show::PublicationDetailsSummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:edition) do
    create(
      :edition,
      :pension,
      scheduled_publication:,
    )
  end

  let(:component) do
    described_class.new(
      edition:,
    )
  end

  describe "when the content block is scheduled" do
    let(:scheduled_publication) { 2.days.from_now }

    it "shows the scheduled date time" do
      edition.schedule!

      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Publication details"

      expect(page).to have_css ".govuk-summary-card__action a[href='#{workflow_path(id: edition.id, step: :schedule_publishing)}']"

      expect(page).to have_css ".govuk-summary-list__key", text: "Scheduled date and time"
      expect(page).to have_css ".govuk-summary-list__value", text: I18n.l(scheduled_publication, format: :long_ordinal)
    end
  end

  describe "when the content block is being updated and published immediately" do
    let(:scheduled_publication) { nil }

    it "shows a publish now row" do
      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Publication details"

      expect(page).to have_css ".govuk-summary-card__action a[href='#{workflow_path(id: edition.id, step: :schedule_publishing)}']"

      expect(page).to have_css ".govuk-summary-list__key", text: "Publish date"
      expect(page).to have_css ".govuk-summary-list__value", text: I18n.l(Time.zone.today, format: :long_ordinal)
    end
  end
end
