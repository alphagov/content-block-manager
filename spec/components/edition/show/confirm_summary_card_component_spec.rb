RSpec.describe Edition::Show::ConfirmSummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation, name: "Department for Example") }
  let(:document) { create(:document, :pension) }
  let(:edition) do
    build_stubbed(:edition, :pension,
                  title: "Some edition title",
                  details: { "interesting_fact" => "value of fact", "something" => { "else" => "value" } },
                  lead_organisation_id: organisation.id,
                  document: document)
  end
  let(:fields) do
    [
      double("field", name: "interesting_fact"),
    ]
  end
  let(:schema) { double(:schema, fields:) }
  let(:helper_stub) { double(:helpers) }

  let(:component) do
    described_class.new(edition:)
  end

  before do
    allow(document).to receive(:schema).and_return(schema)
    allow(Organisation).to receive(:all).and_return([organisation])
    allow(component).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:label_for_title).with(edition.block_type).and_return("Translated title")
    allow(helper_stub).to receive(:workflow_path).with(id: edition.id, step: :edit_draft).and_return("/some-path")
  end

  it "it renders instructions to publishers" do
    edition.instructions_to_publishers = "some instructions"

    render_inline(described_class.new(edition:))

    expect(page).to have_css ".govuk-summary-list__key", text: "Instructions to publishers"
    expect(page).to have_css ".govuk-summary-list__value p", text: "some instructions"
  end

  it "renders a summary card component with the edition details to confirm" do
    allow(document).to receive(:is_new_block?).and_return(false)

    render_inline(component)

    expect(page).to have_css ".govuk-summary-list__row", count: 4

    expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Translated title"
    expect(page).to have_css ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "Some edition title"

    expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Interesting fact"
    expect(page).to have_css ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "value of fact"

    expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Lead organisation"
    expect(page).to have_css ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Department for Example"

    expect(page).to have_css ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Instructions to publishers"
    expect(page).to have_css ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "None"
  end
end
