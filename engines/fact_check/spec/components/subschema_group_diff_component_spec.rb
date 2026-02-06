RSpec.describe FactCheck::SubschemaGroupDiffComponent, type: :component do
  let(:subschema) { build(:schema) }
  let(:schema) do
    build(:schema, block_type: :contact, body:
      { "properties" =>
        { "content_block_contact" => SchemaHelpers::MINIMAL_CONTACT_SCHEMA_BODY } })
  end

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
  let(:combined_block_content) { double }

  let(:items_1) do
    { "title" => { "published" => "Address", "new" => "Address" },
      "street_address" => { "published" => "123 fake street", "new" => "123 real street" },
      "town_or_city" => { "published" => "Springfield", "new" => "Springfield" },
      "state_or_county" => { "new" => "England" } }
  end

  let(:items_2) do
    { "title" => { "published" => "Address again", "new" => "Address again" },
      "street_address" => { "published" => "Foo", "new" => "Bar" } }
  end

  before do
    allow(schema).to receive(:subschema).and_return(subschema)
    allow(subschema).to receive(:id).and_return(subschema_id)
    allow(subschema).to receive(:field) { |name| Schema::Field.new(name, subschema) }
    allow(block).to receive(:published_block).and_return(published_edition)
    allow(combined_block_content).to receive(:fields).with(object_titles[0]).and_return(items_1)
    allow(combined_block_content).to receive(:fields).with(object_titles[1]).and_return(items_2)
  end

  describe "when provided with a list of embedded blocks" do
    let(:embedded_object_titles) { object_titles }

    it "should render a nested block summary for each embedded object provided" do
      expect(FactCheck::NestedBlocksWithSummaryDiffComponent).to receive(:new).with(
        items: items_1,
        object_type: subschema_id,
        object_title: object_titles[0],
        block: block,
      ).and_call_original

      expect(FactCheck::NestedBlocksWithSummaryDiffComponent).to receive(:new).with(
        items: items_2,
        object_type: subschema_id,
        object_title: object_titles[1],
        block: block,
      ).and_call_original

      render_inline(described_class.new(block:, subschema:, embedded_object_titles:, combined_block_content:))

      expect(page).to have_content("Address block", count: 2) do |block|
        expect(block).to have_css(".diff", text: "123 fake streetSpringfield") # ignores '<br>' separators
        expect(block).to have_css(".diff", text: "123 real streetSpringfieldEngland")
      end
    end
  end
end
