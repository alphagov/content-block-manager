RSpec.describe Edition::Show::EmbeddedObjects::SubschemaItemComponent, type: :component do
  let(:schema) { double("schema") }
  let(:subschema) { double("schema") }

  let(:details) do
    {
      "object": {
        "something": {
          "title": "Some title",
          "item_1": "Foo",
          "item_2": "Bar",
          "item_blank": "",
          "other_blank": "",
        },
      },
    }
  end

  let(:edition) { build(:edition, :pension, details:) }
  let(:object_type) { "object" }
  let(:object_title) { "something" }
  let(:schema_name) { "schema_name" }

  let(:component) do
    described_class.new(
      edition:,
      object_type:,
      schema_name:,
      object_title:,
    )
  end

  let(:metadata_response) { "METADATA" }
  let(:block_response) { "BLOCKS" }

  before do
    allow(edition.document).to receive(:schema).and_return(schema)
    allow(schema).to receive(:subschema).with(object_type).and_return(subschema)
    allow(subschema).to receive(:block_display_fields).and_return(%w[item_1 item_2 item_blank])
    allow(subschema).to receive(:field_ordering_rule).with("item_1").and_return(2)
    allow(subschema).to receive(:field_ordering_rule).with("item_2").and_return(1)
    allow(subschema).to receive(:field_ordering_rule).with("title").and_return(3)

    expect(component).to receive(:render).with(metadata_response).and_return(metadata_response)
    expect(component).to receive(:render).with(block_response).and_return(block_response)
  end

  it "renders non-blank fields apart from 'block_display_fields' with the MetadataComponent" do
    allow(Edition::Show::EmbeddedObjects::BlocksComponent).to receive(:new).and_return(block_response)

    expect(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).with(
      items: { "title" => "Some title" },
      schema: subschema,
    ).and_return(metadata_response)

    render_inline component

    expect(page).to have_text metadata_response
  end

  it "renders the (remaining) non-blank 'block_display_fields' with BlocksComponent" do
    allow(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).and_return(metadata_response)

    expect(Edition::Show::EmbeddedObjects::BlocksComponent).to receive(:new).with(
      items: { "item_2" => "Bar", "item_1" => "Foo" },
      object_type:,
      schema_name:,
      object_title:,
      edition: edition,
    ).and_return(block_response)

    render_inline component

    expect(page).to have_text block_response
  end
end
