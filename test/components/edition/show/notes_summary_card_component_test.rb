require "test_helper"

class Edition::Show::NotesSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:edition) do
    create(
      :edition,
      :pension,
      instructions_to_publishers: "some instructions",
      major_change:,
      change_note: "Some change note",
      internal_change_note: "My internal note",
    )
  end

  let(:component) do
    Edition::Show::NotesSummaryCardComponent.new(
      edition:,
    )
  end

  describe "when the change is major" do
    let(:major_change) { true }

    it "shows the public change note" do
      render_inline component

      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Internal note"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "My internal note"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions", text: "Edit"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :internal_note)}']"

      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "Yes"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions", text: "Edit"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"

      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Public change note"
      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Some change note"
      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions", text: "Edit"
      assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"
    end
  end

  describe "when the change is not major" do
    let(:major_change) { false }

    it "shows the public change note" do
      render_inline component

      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Internal note"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "My internal note"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions", text: "Edit"
      assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :internal_note)}']"

      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "No"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions", text: "Edit"
      assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"

      refute_selector ".govuk-summary-list__key", text: "Public change note"
      refute_selector ".govuk-summary-list__value", text: "Some change note"
    end
  end
end
