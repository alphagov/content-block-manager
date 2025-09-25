require "test_helper"

class Shared::EmbeddedObjects::NestedItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:nested_items) do
    { "nested_item_field" => "field *value*" }
  end

  let(:schema) do
    stub(
      "sub-schema",
      name: "schema",
      govspeak_enabled?: true,
    )
  end

  let(:root_schema_name) { "schema" }

  let(:component) do
    Shared::EmbeddedObjects::SummaryCard::NestedItemComponent.new(
      nested_items: nested_items,
      object_key: "nested_object",
      object_type: "schema",
      title: "Nested object",
      subschema: schema,
      root_schema_name: "schema",
    )
  end

  context "when a field is govspeak enabled" do
    it "renders the value as HTML" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      assert_equal(
        "<p>field <em>value</em></p>",
        rendered_value,
      )
    end
  end

  context "when a field is NOT govspeak enabled" do
    let(:schema) do
      stub(
        "sub-schema",
        govspeak_enabled?: false,
      )
    end

    it "renders the value unconverted" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      assert_equal(
        "field *value*",
        rendered_value,
      )
    end
  end

  describe "when a field has a translation" do
    before do
      component.expects(:humanized_label).with(
        schema_name: "schema",
        relative_key: "nested_item_field",
        root_object: "schema.nested_object",
      ).returns("Translated label")
    end

    it "renders the translated value" do
      render_inline component

      assert_selector ".govuk-summary-list__key", text: "Translated label"
    end
  end
end
