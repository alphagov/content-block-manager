RSpec.describe Edition::Show::SubschemaItemsComponent, type: :component do
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

  let(:subschema_relationship_type_predicate) do
    double("relationship type predicate", one_to_one?: false)
  end

  let(:subschema) do
    double(
      "subschema",
      id: "embedded-type",
      name: "Embedded Type",
      relationship_type: subschema_relationship_type_predicate,
    )
  end

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
    context "when the subschemas are in a *one-to-many* relationship with the parent schema" do
      before do
        allow(subschema_relationship_type_predicate).to receive(:one_to_one?).and_return(false)
      end

      it "renders an EmbeddedObjects::SubschemaItemComponent (plural) for each object" do
        summary_list_stub_1 = "my-embedded-object"
        summary_list_stub_2 = "my-other-embedded-object"

        expect(Edition::Show::EmbeddedObjects::SubschemaItemComponent).to receive(:new).with(
          edition:,
          object_type: subschema.id,
          schema_name: schema.block_type,
          object_title: "my-embedded-object",
        ).and_return(summary_list_stub_1)

        expect(Edition::Show::EmbeddedObjects::SubschemaItemComponent).to receive(:new).with(
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

    context "when the subschemas are in a *one-to-one* relationship with the parent schema" do
      before do
        allow(subschema_relationship_type_predicate).to receive(:one_to_one?).and_return(true)
      end

      it "renders an EmbeddedObject::SubschemaItemComponent (singular) for the sole object" do
        summary_list_stub_1 = "my-embedded-object"

        allow(Edition::Show::EmbeddedObject::SubschemaItemComponent).to receive(:new).with(
          edition:,
          object_type: subschema.id,
          schema_name: schema.block_type,
        ).and_return(summary_list_stub_1)

        allow(component).to receive(:render).with(summary_list_stub_1).and_return(summary_list_stub_1)

        render_inline(component)

        expect(page).to have_text summary_list_stub_1
      end
    end
  end
end
