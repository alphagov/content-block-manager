require "test_helper"

class Document::Show::EmbeddedObjects::TabGroupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:subschema_1) { stub("subschema_1", id: "embedded-type-1", name: "embedded type 1", group_order: 1) }
  let(:subschema_2) { stub("subschema_2", id: "embedded-type-2", name: "embedded type 2", group_order: 0) }

  let(:subschemas) do
    [
      subschema_1,
      subschema_2,
    ]
  end

  let(:document) { build(:document, id: SecureRandom.uuid) }
  let(:edition) { build(:edition, :pension, document: document) }

  before do
    document.stubs(:latest_edition).returns(edition)
  end

  let(:component) do
    Document::Show::EmbeddedObjects::TabGroupComponent.new(
      document:,
      subschemas:,
    )
  end

  it "should render a tab for each subschema" do
    tab_component_1_double = stub("TabComponent", id: subschema_1.id, label: "Tab 1", content: "<p>content_1</p>")
    tab_component_2_double = stub("TabComponent", id: subschema_2.id, label: "Tab 2", content: "<p>content_2</p>")

    Document::Show::EmbeddedObjects::SubschemaItemsComponent.expects(:new).with(
      edition:,
      subschema: subschema_1,
    ).returns(tab_component_1_double)

    Document::Show::EmbeddedObjects::SubschemaItemsComponent.expects(:new).with(
      edition:,
      subschema: subschema_2,
    ).returns(tab_component_2_double)

    component.expects(:render).with(tab_component_1_double).returns(tab_component_1_double.content)
    component.expects(:render).with(tab_component_2_double).returns(tab_component_2_double.content)

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

    component.expects(:render).with("govuk_publishing_components/components/tabs", tabs: expected_tabs).returns(tab_double)

    render_inline(component)

    assert_text tab_double
  end
end
