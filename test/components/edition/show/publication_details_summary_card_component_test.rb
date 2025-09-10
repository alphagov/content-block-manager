require "test_helper"

class Edition::Show::PublicationDetailsSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:edition) do
    create(
      :edition,
      :pension,
      scheduled_publication:,
    )
  end

  let(:component) do
    Edition::Show::PublicationDetailsSummaryCardComponent.new(
      edition:,
    )
  end

  describe "when the content block is scheduled" do
    let(:scheduled_publication) { 2.days.from_now }

    it "shows the scheduled date time" do
      edition.schedule!

      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Publication details"

      assert_selector ".govuk-summary-card__action a[href='#{workflow_path(id: edition.id, step: :schedule_publishing)}']"

      assert_selector ".govuk-summary-list__key", text: "Scheduled date and time"
      assert_selector ".govuk-summary-list__value", text: I18n.l(scheduled_publication, format: :long_ordinal)
    end
  end

  describe "when the content block is being updated and published immediately" do
    let(:scheduled_publication) { nil }

    it "shows a publish now row" do
      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Publication details"

      assert_selector ".govuk-summary-card__action a[href='#{workflow_path(id: edition.id, step: :schedule_publishing)}']"

      assert_selector ".govuk-summary-list__key", text: "Publish date"
      assert_selector ".govuk-summary-list__value", text: I18n.l(Time.zone.today, format: :long_ordinal)
    end
  end
end
