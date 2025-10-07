require "test_helper"

class Document::Show::EmbeddedObjects::SubschemaItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:schema) { stub("schema") }
  let(:subschema) { stub("schema") }

  let(:details) do
    {
      "object": {
        "something": {
          "title": "Some title",
          "item_1": "Foo",
          "item_2": "Bar",
          "item_blank": "",
          "other_blank": "",
        },
      },
    }
  end

  let(:edition) { build(:edition, :pension, details:) }
  let(:object_type) { "object" }
  let(:object_title) { "something" }
  let(:schema_name) { "schema_name" }

  let(:component) do
    Document::Show::EmbeddedObjects::SubschemaItemComponent.new(
      edition:,
      object_type:,
      schema_name:,
      object_title:,
    )
  end

  let(:metadata_response) { "METADATA" }
  let(:block_response) { "BLOCKS" }

  before do
    edition.document.stubs(:schema).returns(schema)
    schema.stubs(:subschema).with(object_type).returns(subschema)
    subschema.stubs(:block_display_fields).returns(%w[item_1 item_2 item_blank])
    subschema.stubs(:field_ordering_rule).with("item_1").returns(2)
    subschema.stubs(:field_ordering_rule).with("item_2").returns(1)
    subschema.stubs(:field_ordering_rule).with("title").returns(3)

    component.expects(:render).with(metadata_response).returns(metadata_response)
    component.expects(:render).with(block_response).returns(block_response)
  end

  it "renders non-blank fields apart from 'block_display_fields' with the MetadataComponent" do
    Document::Show::EmbeddedObjects::BlocksComponent.stubs(:new).returns(block_response)

    Document::Show::EmbeddedObjects::MetadataComponent.expects(:new).with(
      items: { "title" => "Some title" },
      object_type:,
      schema_name:,
      schema: subschema,
    ).returns(metadata_response)

    render_inline component

    assert_text metadata_response
  end

  it "renders the (remaining) non-blank 'block_display_fields' with BlocksComponent" do
    Document::Show::EmbeddedObjects::MetadataComponent.stubs(:new).returns(metadata_response)

    Document::Show::EmbeddedObjects::BlocksComponent.expects(:new).with(
      items: { "item_2" => "Bar", "item_1" => "Foo" },
      object_type:,
      schema_name:,
      object_title:,
      document: edition.document,
    ).returns(block_response)

    render_inline component

    assert_text block_response
  end
end
