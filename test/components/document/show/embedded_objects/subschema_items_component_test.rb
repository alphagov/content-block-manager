require "test_helper"

class Document::Show::EmbeddedObjects::SubschemaItemsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
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

  let(:schema) { stub("schema", block_type: "schema") }
  let(:subschema) { stub("subschema", id: "embedded-type", name: "Embedded Type") }

  let(:document) { build(:document, id: SecureRandom.uuid) }
  let(:edition) { build(:edition, :pension, details:, document: document) }

  let(:component) do
    Document::Show::EmbeddedObjects::SubschemaItemsComponent.new(
      edition:,
      schema:,
      subschema:,
    )
  end

  describe "#id" do
    it "returns the sub-schema's ID" do
      assert_equal component.id, subschema.id
    end
  end

  describe "#label" do
    it "returns the sub-schema's name and count of objects" do
      assert_equal component.label, "Embedded Types (2)"
    end
  end

  describe "rendering" do
    it "renders a SummaryListComponent for each object" do
      summary_list_stub_1 = "my-embedded-object"
      summary_list_stub_2 = "my-other-embedded-object"

      Document::Show::EmbeddedObjects::SubschemaItemComponent.expects(:new).with(
        edition:,
        object_type: subschema.id,
        schema_name: schema.block_type,
        object_title: "my-embedded-object",
      ).returns(summary_list_stub_1)

      Document::Show::EmbeddedObjects::SubschemaItemComponent.expects(:new).with(
        edition:,
        object_type: subschema.id,
        schema_name: schema.block_type,
        object_title: "my-other-embedded-object",
      ).returns(summary_list_stub_2)

      component.expects(:render).with(summary_list_stub_1).returns(summary_list_stub_1)
      component.expects(:render).with(summary_list_stub_2).returns(summary_list_stub_2)

      render_inline(component)

      assert_text summary_list_stub_1
      assert_text summary_list_stub_2
    end
  end
end
