RSpec.describe Document::Index::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include EditionHelper

  let(:document) { build_stubbed(:document, :pension) }
  let(:organisation) { build(:organisation) }
  let(:edition) do
    build_stubbed(
      :edition,
      :pension,
      id: 123,
      details: { foo: "bar", something: "else" },
      creator: build(:user),
      lead_organisation_id: organisation.id,
      scheduled_publication: Time.zone.now,
      state: "published",
      updated_at: 1.day.ago,
      document: document,
    )
  end
  let(:fields) do
    [
      double(:field, name: "foo"),
      double(:field, name: "something"),
    ]
  end
  let(:schema) { double(:schema, fields:) }

  before do
    expect(document).to receive(:most_recent_edition).at_least(:once).and_return(edition)
    allow(edition).to receive(:schema).and_return(schema)
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  it "renders a published content block as a summary card" do
    render_inline(described_class.new(document:))

    expect(page).to have_css ".govuk-summary-card__title", text: edition.title
    expect(page).to have_css ".govuk-summary-card__action", count: 1
    expect(page).to have_css ".govuk-summary-card__action .govuk-link[href='#{document_path(document)}']"

    expect(page).to have_css ".govuk-link", text: "View"

    expect(page).to have_css ".govuk-summary-list__row", count: 6

    expect(page).to have_css ".govuk-summary-list__key", text: "Title"
    expect(page).to have_css ".govuk-summary-list__value", text: edition.title

    expect(page).to have_css ".govuk-summary-list__key", text: "Foo"
    expect(page).to have_css ".govuk-summary-list__value", text: "bar"

    expect(page).to have_css ".govuk-summary-list__key", text: "Something"
    expect(page).to have_css ".govuk-summary-list__value", text: "else"

    expect(page).to have_css ".govuk-summary-list__key", text: "Lead organisation"
    expect(page).to have_css ".govuk-summary-list__value", text: edition.lead_organisation.name

    expect(page).to have_css ".govuk-summary-list__key", text: "Status"
    expect(page).to have_css ".govuk-summary-list__value", text: "Published on #{strip_tags updated_date(edition)} by #{edition.creator.name}"
  end

  describe "when the edition is scheduled" do
    it "returns the scheduled value" do
      edition.state = "scheduled"
      edition.scheduled_publication = Time.zone.now

      render_inline(described_class.new(document:))

      expect(page).to have_css ".govuk-summary-list__row", count: 6

      expect(page).to have_css ".govuk-summary-list__key", text: "Status"
      expect(page).to have_css ".govuk-summary-list__value", text: "Scheduled for publication at #{strip_tags scheduled_date(edition)}"
    end
  end
end
