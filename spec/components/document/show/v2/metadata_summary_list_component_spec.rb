RSpec.describe V2::Document::Show::MetadataSummaryListComponent, type: :component do
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include EditionHelper

  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation, name: "Department for Example") }
  let(:document) { build_stubbed(:v2_document) }
  let!(:edition) do
    build_stubbed(
      :v2_time_period_edition,
      description: "some defined period of time",
      instructions_to_publishers: "some instructions",
      creator: build(:user),
      lead_organisation_id: organisation.id,
      state: "published",
      updated_at: 1.day.ago,
      document: document,
    )
  end

  before do
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  it "renders a content block's metadata" do
    component = described_class.new(edition: edition)
    allow(component).to receive(:current_state_label).with(edition).and_return("some notes about the current state")

    render_inline(component)

    expect(page).to have_css ".govuk-summary-list__row", count: 5

    expect(page).to have_summary_row.with_key("Time period name").with_value(edition.title)
    expect(page).to have_summary_row.with_key("Description").with_value(edition.description)
    expect(page).to have_summary_row.with_key("Lead organisation").with_value(edition.lead_organisation.name)
    expect(page).to have_summary_row.with_key("Instructions to publishers").with_value(edition.instructions_to_publishers)
    expect(page).to have_summary_row.with_key("Status").with_value("some notes about the current state")
  end
end
