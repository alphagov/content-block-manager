RSpec.describe Edition::Show::EmbeddedObjects::TabGroupComponent, type: :component do
  let(:schema) { double("schema") }

  let(:subschema_1) { double("subschema_1", id: "embedded-type-1", name: "embedded type 1", group_order: 1) }
  let(:subschema_2) { double("subschema_2", id: "embedded-type-2", name: "embedded type 2", group_order: 0) }

  let(:subschemas) do
    [
      subschema_1,
      subschema_2,
    ]
  end

  let(:edition) { build(:edition, :pension) }

  let(:component) do
    described_class.new(
      edition: edition,
      schema:,
      subschemas:,
    )
  end

  it "should render a tab for each subschema" do
    tab_component_1_double = double("TabComponent", id: subschema_1.id, label: "Tab 1", content: "<p>content_1</p>")
    tab_component_2_double = double("TabComponent", id: subschema_2.id, label: "Tab 2", content: "<p>content_2</p>")

    expect(Edition::Show::EmbeddedObjects::SubschemaItemsComponent).to receive(:new).with(
      edition:,
      schema:,
      subschema: subschema_1,
    ).and_return(tab_component_1_double)

    expect(Edition::Show::EmbeddedObjects::SubschemaItemsComponent).to receive(:new).with(
      edition:,
      schema:,
      subschema: subschema_2,
    ).and_return(tab_component_2_double)

    expect(component).to receive(:render).with(tab_component_1_double).and_return(tab_component_1_double.content)
    expect(component).to receive(:render).with(tab_component_2_double).and_return(tab_component_2_double.content)

    expected_tabs = [
      {
        id: tab_component_2_double.id,
        label: tab_component_2_double.label,
        content: tab_component_2_double.content,
      },
      {
        id: tab_component_1_double.id,
        label: tab_component_1_double.label,
        content: tab_component_1_double.content,
      },
    ]

    tab_double = "TAB CONTENT"

    expect(component).to receive(:render).with("govuk_publishing_components/components/tabs", { tabs: expected_tabs }).and_return(tab_double)

    render_inline(component)

    expect(page).to have_text tab_double
  end
end
