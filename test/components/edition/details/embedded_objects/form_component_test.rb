require "test_helper"

class Edition::Details::EmbeddedObjects::FormComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:edition) { build(:edition) }

  let(:block_type) { "some_object" }
  let(:subschema) { build(:schema, block_type:) }

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:enum_field) { stub("field", name: "enum", component_name: "enum", enum_values: ["some value", "another value"], default_value: "some value", data_attributes: nil) }
  let(:textarea_field) { stub("field", name: "enum", component_name: "textarea", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:boolean_field) { stub("field", name: "boolean", component_name: "boolean", enum_values: nil, default_value: nil, data_attributes: nil) }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:enum_stub) { stub("enum_component") }
  let(:textarea_stub) { stub("textarea_component") }
  let(:boolean_stub) { stub("boolean_component") }

  let(:schema) { stub(:schema) }

  before do
    subschema.stubs(:fields).returns([foo_field, bar_field, enum_field, textarea_field, boolean_field])
  end

  it "renders fields for each property" do
    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: foo_field,
      subschema:,
      schema:,
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: bar_field,
      subschema:,
      schema:,
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.expects(:new).with(
      edition:,
      field: enum_field,
      subschema:,
      enum: ["some value", "another value"],
      default: "some value",
      schema:,
    ).returns(enum_stub)

    Edition::Details::Fields::TextareaComponent.expects(:new).with(
      edition:,
      field: textarea_field,
      subschema:,
      schema:,
    ).returns(textarea_stub)

    Edition::Details::Fields::BooleanComponent.expects(:new).with(
      edition:,
      field: boolean_field,
      subschema:,
      schema:,
    ).returns(boolean_stub)

    component = Edition::Details::EmbeddedObjects::FormComponent.new(
      edition:,
      subschema:,
      schema:,
      params: nil,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end

  it "sends the value of a field if present in the params argument" do
    params = { "foo" => "something" }

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: foo_field,
      subschema:,
      schema:,
      value: "something",
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: bar_field,
      subschema:,
      schema:,
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.expects(:new).with(
      edition:,
      field: enum_field,
      subschema:,
      schema:,
      enum: ["some value", "another value"],
      default: "some value",
    ).returns(enum_stub)

    Edition::Details::Fields::TextareaComponent.expects(:new).with(
      edition:,
      field: textarea_field,
      subschema:,
      schema:,
    ).returns(textarea_stub)

    Edition::Details::Fields::BooleanComponent.expects(:new).with(
      edition:,
      field: boolean_field,
      subschema:,
      schema:,
    ).returns(boolean_stub)

    component = Edition::Details::EmbeddedObjects::FormComponent.new(
      edition:,
      subschema:,
      params:,
      schema:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end

  it "sends the subschema's block_type as an `object_title` if provided" do
    object_title = "something"

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: foo_field,
      subschema:,
      schema:,
      object_title:,
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: bar_field,
      subschema:,
      schema:,
      object_title:,
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.expects(:new).with(
      edition:,
      field: enum_field,
      subschema:,
      schema:,
      enum: ["some value", "another value"],
      default: "some value",
      object_title:,
    ).returns(enum_stub)

    Edition::Details::Fields::TextareaComponent.expects(:new).with(
      edition:,
      field: textarea_field,
      subschema:,
      schema:,
      object_title:,
    ).returns(textarea_stub)

    Edition::Details::Fields::BooleanComponent.expects(:new).with(
      edition:,
      field: boolean_field,
      subschema:,
      schema:,
      object_title:,
    ).returns(boolean_stub)

    component = Edition::Details::EmbeddedObjects::FormComponent.new(
      edition:,
      subschema:,
      schema:,
      params: nil,
      object_title:,
    )

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end
end
