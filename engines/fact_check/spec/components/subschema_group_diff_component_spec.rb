RSpec.describe FactCheck::SubschemaGroupDiffComponent, type: :component do
  let(:subschema) { build(:schema, body: SchemaHelpers::REALISTIC_CONTACT_SCHEMA_BODY) }
  let(:schema) { build(:schema, block_type: :contact, body: { "properties" =>
                                                              { "content_block_contact" => SchemaHelpers::REALISTIC_CONTACT_SCHEMA_BODY } }) }

  let(:document) { build(:document, :contact, schema:) }

  let(:edition) { build(:edition, document:, details: {}) }
  let(:block) { build(:content_block, edition:) }

  let(:published_edition) { build(:edition, document:, details: {}) }
  let(:published_block) { build(:content_block, edition: published_edition) }

  let(:combined_block_content) { spy }

  before do
    allow(schema).to receive(:subschema).and_return(subschema)
    allow(subschema).to receive(:field) { |name| Schema::Field.new(name, subschema) }
    allow(subschema).to receive(:block_type).and_return(:contact)
    allow(block).to receive(:published_block).and_return(published_block)
    allow(combined_block_content).to receive(:fields).with("address").and_return(
      { "title" => { "published" => "Address", "new" => "Address" },
        "street_address" => { "published" => "123 fake street", "new" => "123 real street" },
        "town_or_city" => { "published" => "Springfield", "new" => "Springfield" },
        "state_or_county" => { "new" => "England" } },
    )

    render_inline(described_class.new(block:, subschema:, embedded_object_titles:, combined_block_content:))
  end

  describe "when provided with a list of embedded blocks" do
    let(:embedded_object_titles) { %w[address] }

    it "should render a nested block summary for each embedded object provided" do
      output = %(
           <link rel="stylesheet" href="http://localhost:3000/assets/content-block-manager/application.debug.css"></link>
           #{page.native}
      )

      file_name = "/Users/graham.macgregor/govuk/content-block-manager/graham-test.html"
      File.open(file_name, "w") do |f|
        f.write(output)
      end
    end
  end
end
