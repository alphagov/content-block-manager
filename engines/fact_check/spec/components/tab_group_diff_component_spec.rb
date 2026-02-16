RSpec.describe FactCheck::TabGroupDiffComponent, type: :component do
  let(:schema) { build(:schema, block_type: :contact, body: SchemaHelpers::MINIMAL_CONTACT_SCHEMA_BODY) }

  let(:published_details) do
    { subschema_id =>
      { object_titles[0] =>
        { "title" => "Address",
          "street_address" => "123 fake street",
          "town_or_city" => "Springfield" },
        object_titles[1] =>
        { "title" => "Address again",
          "street_address" => "Foo" } } }
  end

  let(:new_details) do
    { subschema_id =>
      { object_titles[0] =>
        { "title" => "Address",
          "street_address" => "123 real street",
          "town_or_city" => "Springfield",
          "state_or_county" => "England" },
        object_titles[1] =>
        { "title" => "Address again",
          "street_address" => "Bar" } } }
  end

  let(:object_titles) { %w[address-1 address-2] }
  let(:subschema_id) { "addresses" }
  let(:document) { build(:document, :contact, schema:) }
  let(:edition) { build(:edition, :awaiting_factcheck, document:, details: new_details) }
  let(:block) { build(:content_block, edition:) }
  let(:published_edition) { build(:edition, :published, document:, details: published_details) }

  describe "when given a list of subschemas" do
    let(:subschemas) do
      [Schema::EmbeddedSchema.new("addresses", {}, schema),
       Schema::EmbeddedSchema.new("contact_links", {}, schema)]
    end

    before do
      allow(block).to receive(:published_block).and_return(published_edition)
      render_inline(described_class.new(block:, subschemas:))
    end

    it "should render one tab per subschema" do
      expect(page).to have_css(".govuk-tabs", count: 1)
      tabs = page.find_all(".govuk-tabs__list-item", count: 2)
      expect(tabs[0]).to have_content "Address (2)"
      expect(tabs[1]).to have_content "Contact link (0)"
    end

    it "should render a the subschema blocks for each tab" do
      expect(page).to have_css(".gem-c-summary-card", text: "Address block", count: 2)

      cards = page.find_all(".gem-c-summary-card")
      expect(cards[0]).to have_content("123 fake street")
      expect(cards[0]).to have_content("123 real street")

      expect(cards[1]).to have_content("Foo")
      expect(cards[1]).to have_content("Bar")
    end
  end
end
