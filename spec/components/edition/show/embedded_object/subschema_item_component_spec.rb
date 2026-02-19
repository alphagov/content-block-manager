RSpec.describe Edition::Show::EmbeddedObject::SubschemaItemComponent, type: :component do
  let(:schema) { double("schema: time period") }
  let(:subschema) { double("subschema: date_range") }

  let(:details) do
    {
      "date_range" => {
        "end" => { "date" => "2026-04-05", "time" => "23:59" },
        "start" => { "date" => "2025-04-06", "time" => "00:00" },
        "other_blank" => "",
        "other_field" => "Other value",
      },
    }
  end

  let(:edition) { build(:edition, :pension, details: details) }
  let(:object_type) { "date_range" }
  let(:schema_name) { "date_range" }

  let(:component) do
    described_class.new(
      edition:,
      object_type:,
      schema_name:,
    )
  end

  let(:metadata_response) { "METADATA" }
  let(:block_response) { "BLOCKS" }

  before do
    allow(edition.document).to receive(:schema).and_return(schema)
    allow(schema).to receive(:subschema).with(object_type).and_return(subschema)
    allow(subschema).to receive(:id).and_return(object_type)
    allow(subschema).to receive(:block_display_fields).and_return(%w[start end])
    allow(subschema).to receive(:field_ordering_rule).with("start").and_return(1)
    allow(subschema).to receive(:field_ordering_rule).with("end").and_return(2)
    allow(subschema).to receive(:field_ordering_rule).with("title").and_return(3)

    expect(component).to receive(:render).with(metadata_response).and_return(metadata_response)
    expect(component).to receive(:render).with(block_response).and_return(block_response)
  end

  it "renders non-blank fields apart from 'block_display_fields' with the MetadataComponent" do
    allow(Edition::Show::EmbeddedObjects::BlocksComponent).to receive(:new).and_return(block_response)

    expect(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).with(
      items: { "other_field" => "Other value" },
      schema: subschema,
    ).and_return(metadata_response)

    render_inline component

    expect(page).to have_text metadata_response
  end

  it "renders the (remaining) non-blank 'block_display_fields' with BlocksComponent" do
    allow(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).and_return(metadata_response)

    expect(Edition::Show::EmbeddedObjects::BlocksComponent).to receive(:new).with(
      items: { "end" => { "date" => "2026-04-05", "time" => "23:59" },
               "start" => { "date" => "2025-04-06", "time" => "00:00" } },
      object_type: "date_range",
      object_title: nil,
      schema_name: "date_range",
      edition: edition,
    ).and_return(block_response)

    render_inline component

    expect(page).to have_text block_response
  end
end
