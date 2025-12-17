RSpec.describe Shared::EmbeddedObjects::SummaryCard::NestedItemComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:field_name) { "nested_item_field" }
  let(:field_value) { "field *value*" }
  let(:response) { "GOVSPEAK FORMATTED VALUE" }

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
      object_key: "nested_object",
      object_type: "schema",
      title: "Nested object",
      subschema: schema,
      root_schema_name: "schema",
    )
  end

  before do
    allow(component).to receive(:render_govspeak_if_enabled_for_field).with(
      field_name:,
      value: field_value,
    ).and_return(response)
  end

  it "renders the value as HTML" do
    render_inline component
    rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

    expect(rendered_value).to eq(response)
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
