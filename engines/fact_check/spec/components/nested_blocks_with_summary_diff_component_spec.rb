RSpec.describe FactCheck::NestedBlocksWithSummaryDiffComponent, type: :component do
  let(:items) do
    { "title" => { "published" => "Address", "new" => "Address" },
      "street_address" => { "published" => "123 fake street", "new" => "123 real street" },
      "town_or_city" => { "published" => "Springfield", "new" => "Springfield" },
      "state_or_county" => { "new" => "England" } }
  end

  let(:published_details) do
    { "addresses" =>
      { "address-1" =>
        { "title" => "Address",
          "street_address" => "123 fake street",
          "town_or_city" => "Springfield" } } }
  end

  let(:new_details) do
    { "addresses" =>
      { "address-1" =>
        { "title" => "Address",
          "street_address" => "123 real street",
          "town_or_city" => "Springfield",
          "state_or_county" => "England" } } }
  end

  let(:object_type) { "addresses" }
  let(:object_title) { "address-1" }

  let(:schema) { build(:schema, body: SchemaHelpers::MINIMAL_CONTACT_SCHEMA_BODY) }
  let(:document) { create(:document, :contact, schema:) }
  let(:pub_edition) { build(:edition, :contact, :published, document:, details: published_details) }
  let(:edition) { build(:edition, :contact, :awaiting_factcheck, document:, details: new_details) }
  let(:block) { build(:content_block, edition:) }
  let(:component) { described_class.new(items:, object_type:, object_title:, block:) }

  before do
    allow(document).to receive(:latest_published_edition).and_return(pub_edition)
    render_inline(component)
  end

  it "should render a summary diff of the whole block" do
    expect(page).to have_css(".app-c-embedded-objects-blocks-component", count: 1) do |full_component|
      expect(full_component).to have_css(".govuk-summary-card", count: 1) do |summary|
        expect(summary).to have_css(".diff del", text: "123 fake street")
        expect(summary).to have_css(".diff del", text: "Springfield")

        expect(summary).to have_css(".diff ins", text: "123 real street")
        expect(summary).to have_css(".diff ins", text: "Springfield")
        expect(summary).to have_css(".diff ins", text: "England")
      end
    end
  end

  it "should render a nested diff of each item individually" do
    lists = page.all(".govuk-summary-list", count: 2, visible: false)
    rows = lists[1].all(".govuk-summary-list__row", count: 4, visible: false)

    expect(rows[0]).to have_content("Title")
    expect(rows[0]).to have_content("Address")

    expect(rows[1]).to have_content("Street address")
    expect(rows[1]).to have_content("123 fake street")
    expect(rows[1]).to have_content("123 real street")

    expect(rows[2]).to have_content("Town or city")
    expect(rows[2]).to have_content("Springfield")

    expect(rows[3]).to have_content("State or county")
    expect(rows[3]).to have_content("England")
  end
end
