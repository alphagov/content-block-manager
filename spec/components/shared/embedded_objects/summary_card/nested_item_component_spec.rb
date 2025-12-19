RSpec.describe Shared::EmbeddedObjects::SummaryCard::NestedItemComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:field_name) { "nested_item_field" }
  let(:field_value) { "field *value*" }
  let(:govspeak_formatted_value) { "GOVSPEAK FORMATTED VALUE" }

  let(:nested_field) { build(:field, name: field_name, govspeak_enabled?: govspeak_enabled, label: "Field") }
  let(:field) { build(:field, name: "nested_object", title: "Nested object") }
  let(:govspeak_enabled) { false }
  let(:nested_items_counter) { nil }

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
      nested_items_counter:,
    )
  end

  before do
    allow(field).to receive(:nested_field).with(field_name).and_return(nested_field)
    allow(component).to receive(:render_govspeak).with(field_value).and_return(govspeak_formatted_value)
  end

  it "shows the field title and nested labels" do
    render_inline component

    expect(page).to have_css(".govuk-summary-card__title", text: "Nested object")
    expect(page).to have_css("dt.govuk-summary-list__key", text: "Field")
  end

  context "when the nested_items_counter is present" do
    let(:nested_items_counter) { 2 }

    it "appends a counter to the title" do
      render_inline component

      expect(page).to have_css(".govuk-summary-card__title", text: "Nested object 3")
    end
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
end
