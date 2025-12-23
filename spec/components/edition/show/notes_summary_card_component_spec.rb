RSpec.describe Edition::Show::NotesSummaryCardComponent, type: :component do
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
    described_class.new(edition:)
  end

  describe "when the change is major" do
    let(:major_change) { true }

    it "shows the public change note" do
      render_inline component

      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Internal note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "My internal note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions", text: "Edit"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :internal_note)}']"

      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "Yes"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions", text: "Edit"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"

      expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Public change note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Some change note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions", text: "Edit"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"
    end
  end

  describe "when the change is not major" do
    let(:major_change) { false }

    it "shows the public change note" do
      render_inline component

      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Internal note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "My internal note"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions", text: "Edit"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :internal_note)}']"

      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "No"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions", text: "Edit"
      expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{workflow_path(id: edition.id, step: :change_note)}']"

      expect(page).not_to have_css ".govuk-summary-list__key", text: "Public change note"
      expect(page).not_to have_css ".govuk-summary-list__value", text: "Some change note"
    end
  end
end
