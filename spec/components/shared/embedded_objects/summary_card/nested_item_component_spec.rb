RSpec.describe Shared::EmbeddedObjects::SummaryCard::NestedItemComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:field_name) { "nested_item_field" }
  let(:field_value) { "field *value*" }
  let(:govspeak_formatted_value) { "GOVSPEAK FORMATTED VALUE" }

  let(:nested_field) { double("field", name: field_name, govspeak_enabled?: govspeak_enabled) }
  let(:field) { double("field", name: "nested_object") }
  let(:govspeak_enabled) { false }

  let(:nested_items) do
    { field_name => field_value }
  end

  let(:schema) do
    double(
      "sub-schema",
      name: "schema",
    )
  end

  let(:root_schema_name) { "schema" }

  let(:component) do
    Shared::EmbeddedObjects::SummaryCard::NestedItemComponent.new(
      nested_items: nested_items,
      field:,
      object_type: "schema",
      title: "Nested object",
      subschema: schema,
      root_schema_name: "schema",
    )
  end

  before do
    allow(field).to receive(:nested_field).with(field_name).and_return(nested_field)
    allow(component).to receive(:render_govspeak).with(field_value).and_return(govspeak_formatted_value)
  end

  describe "when the field supports govspeak" do
    let(:govspeak_enabled) { true }

    it "renders the value as HTML" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      expect(rendered_value).to eq(govspeak_formatted_value)

      expect(component).to have_received(:render_govspeak).with(field_value)
    end
  end

  describe "when the field does not support govspeak" do
    let(:govspeak_enabled) { false }

    it "renders the value as plain text" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      expect(rendered_value).to eq(field_value)

      expect(component).to_not have_received(:render_govspeak).with(field_value)
    end
  end

  describe "when a field has a translation" do
    before do
      expect(component).to receive(:humanized_label).with(
        schema_name: "schema",
        relative_key: "nested_item_field",
        root_object: "schema.nested_object",
      ).and_return("Translated label")
    end

    it "renders the translated value" do
      render_inline component

      expect(page).to have_css ".govuk-summary-list__key", text: "Translated label"
    end
  end
end
