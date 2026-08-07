RSpec.describe Document::Index::V2::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:document) { build_stubbed(:v2_document, block_type: "time_period") }
  let(:organisation) { build(:organisation) }

  let(:edition) do
    build_stubbed(
      :v2_time_period_edition,
      id: 123,
      description: "some time period description",
      lead_organisation_id: organisation.id,
      updated_at: 1.day.ago,
      document: document,
    )
  end

  before do
    expect(document).to receive(:most_recent_edition).at_least(:once).and_return(edition)
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  it "renders a content block as a summary card" do
    render_inline(described_class.new(document:))

    expect(page).to have_css ".govuk-summary-card__title", text: edition.title
    expect(page).to have_css ".govuk-summary-card__action", count: 1
    expect(page).to have_css ".govuk-summary-card__action .govuk-link[href='']"

    expect(page).to have_css ".govuk-link", text: "View"

    expect(page).to have_css ".govuk-summary-list__row", count: 3

    expect(page).to have_summary_row.with_key("Time period name").with_value(edition.title)

    expect(page).to have_summary_row.with_key("Description").with_value(edition.description)

    expect(page).to have_summary_row.with_key("Lead organisation").with_value(edition.lead_organisation.name)
  end
end
