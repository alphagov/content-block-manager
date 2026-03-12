RSpec.describe Edition::Show::EmbeddedObject::SubschemaItemComponent, type: :component do
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

  let(:edition_with_sole_date_range_object) { build(:edition, :time_period, details: details) }

  let(:component) do
    described_class.new(
      edition: edition_with_sole_date_range_object,
      object_type: "date_range",
      schema_name: "date_range",
    )
  end

  let(:metadata_response) { "METADATA" }
  let(:block_response) { "BLOCKS" }

  before do
    expect(component).to receive(:render).with(metadata_response).and_return(metadata_response)
    allow(component).to receive(:render).with(block_response).and_return(block_response)
  end

  it "renders non-blank fields apart from 'block_display_fields' with the MetadataComponent" do
    expected_subschema = edition_with_sole_date_range_object.schema.subschema("date_range")

    allow(Edition::Show::EmbeddedObjects::BlocksComponent).to receive(:new).and_return(block_response)

    expect(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).with(
      items: { "other_field" => "Other value" },
      schema: expected_subschema,
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
      edition: edition_with_sole_date_range_object,
    ).and_return(block_response)

    render_inline component

    expect(page).to have_text block_response
  end

  context "when there is no data present in 'details' for the embedded object" do
    let(:details) do
      {
        "description" => "This describes the block",
      }
    end

    before do
      allow(Edition::Show::EmbeddedObjects::MetadataComponent).to receive(:new).and_return(metadata_response)
    end

    it "does not render the BlocksComponent" do
      expect(Edition::Show::EmbeddedObjects::BlocksComponent).not_to receive(:new)

      render_inline component
    end
  end
end
