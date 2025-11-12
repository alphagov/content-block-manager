RSpec.describe Document::Show::EmbeddedObjects::SubschemaItemsComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:details) do
    {
      "embedded-type" => {
        "my-embedded-object" => {
          "title" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
        "my-other-embedded-object" => {
          "title" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:schema) { double("schema", block_type: "schema") }
  let(:subschema) { double("subschema", id: "embedded-type", name: "Embedded Type") }

  let(:document) { build(:document, id: SecureRandom.uuid) }
  let(:edition) { build(:edition, :pension, details:, document: document) }

  let(:component) do
    described_class.new(
      edition:,
      schema:,
      subschema:,
    )
  end

  describe "#id" do
    it "returns the sub-schema's ID" do
      expect(subschema.id).to eq(component.id)
    end
  end

  describe "#label" do
    it "returns the sub-schema's name and count of objects" do
      expect("Embedded type (2)").to eq(component.label)
    end
  end

  describe "rendering" do
    it "renders a SummaryListComponent for each object" do
      summary_list_stub_1 = "my-embedded-object"
      summary_list_stub_2 = "my-other-embedded-object"

      expect(Document::Show::EmbeddedObjects::SubschemaItemComponent).to receive(:new).with(
        edition:,
        object_type: subschema.id,
        schema_name: schema.block_type,
        object_title: "my-embedded-object",
      ).and_return(summary_list_stub_1)

      expect(Document::Show::EmbeddedObjects::SubschemaItemComponent).to receive(:new).with(
        edition:,
        object_type: subschema.id,
        schema_name: schema.block_type,
        object_title: "my-other-embedded-object",
      ).and_return(summary_list_stub_2)

      expect(component).to receive(:render).with(summary_list_stub_1).and_return(summary_list_stub_1)
      expect(component).to receive(:render).with(summary_list_stub_2).and_return(summary_list_stub_2)

      render_inline(component)

      expect(page).to have_text summary_list_stub_1
      expect(page).to have_text summary_list_stub_2
    end
  end
end
