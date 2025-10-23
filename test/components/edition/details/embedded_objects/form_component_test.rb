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

  let(:params) { nil }
  let(:populate_with_defaults) { true }
  let(:object_title) { nil }

  let(:component) do
    Edition::Details::EmbeddedObjects::FormComponent.new(
      edition:,
      subschema:,
      schema:,
      params:,
      populate_with_defaults:,
      object_title:,
    )
  end

  before do
    subschema.stubs(:fields).returns([foo_field, bar_field, enum_field, textarea_field, boolean_field])

    Edition::Details::Fields::StringComponent.stubs(:new).with(
      has_entries(field: foo_field),
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.stubs(:new).with(
      has_entries(field: bar_field),
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.stubs(:new).with(
      has_entries(field: enum_field),
    ).returns(enum_stub)

    Edition::Details::Fields::TextareaComponent.stubs(:new).with(
      has_entries(field: textarea_field),
    ).returns(enum_stub)

    Edition::Details::Fields::BooleanComponent.stubs(:new).with(
      has_entries(field: boolean_field),
    ).returns(boolean_stub)

    component.stubs(:render).with(anything)
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
      value: "some value",
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

    component.expects(:render).with(foo_stub)
    component.expects(:render).with(bar_stub)
    component.expects(:render).with(enum_stub)
    component.expects(:render).with(textarea_stub)
    component.expects(:render).with(boolean_stub)

    render_inline(component)
  end

  describe "when params are present" do
    let(:params) { { "foo" => "something" } }

    it "sends the value of a field if present in the params argument" do
      Edition::Details::Fields::StringComponent.expects(:new).with(
        has_entries(field: foo_field, value: "something"),
      ).returns(foo_stub)

      render_inline(component)
    end
  end

  describe "when `object_title` is provided" do
    let(:object_title) { "something" }

    it "sends the subschema's block_type as an `object_title` if provided" do
      Edition::Details::Fields::StringComponent.expects(:new).with(
        has_entries(field: foo_field, object_title:),
      ).returns(foo_stub)

      Edition::Details::Fields::StringComponent.expects(:new).with(
        has_entries(field: bar_field, object_title:),
      ).returns(bar_stub)

      Edition::Details::Fields::EnumComponent.expects(:new).with(
        has_entries(field: enum_field, object_title:),
      ).returns(enum_stub)

      Edition::Details::Fields::TextareaComponent.expects(:new).with(
        has_entries(field: textarea_field, object_title:),
      ).returns(textarea_stub)

      Edition::Details::Fields::BooleanComponent.expects(:new).with(
        has_entries(field: boolean_field, object_title:),
      ).returns(boolean_stub)

      render_inline(component)
    end
  end

  describe "value" do
    before do
      foo_field.stubs(:default_value).returns(default_value)
    end

    describe "when a default value is available for a field" do
      let(:default_value) { "default value" }

      describe "and no value is present in the params" do
        let(:params) { {} }

        describe "and populate_with_defaults is true" do
          let(:populate_with_defaults) { true }

          it "sends the default value" do
            Edition::Details::Fields::StringComponent.expects(:new).with(
              has_entries(field: foo_field, value: default_value),
            ).returns(foo_stub)

            render_inline(component)
          end
        end

        describe "and populate_with_defaults is false" do
          let(:populate_with_defaults) { false }

          it "does not send the default value" do
            Edition::Details::Fields::StringComponent.expects(:new).with(
              has_entries(field: foo_field),
              Not(has_entries(value: anything)),
            ).returns(foo_stub)

            component.expects(:render).with(foo_stub)

            render_inline(component)
          end
        end
      end
    end

    describe "when a default value is not available for a field" do
      let(:default_value) { nil }

      describe "and no value is present in the params" do
        let(:params) { {} }

        describe "and populate_with_defaults is true" do
          let(:populate_with_defaults) { true }

          it "does not send a value" do
            Edition::Details::Fields::StringComponent.expects(:new).with(
              has_entries(field: foo_field),
              Not(has_entries(value: anything)),
            ).returns(foo_stub)

            component.expects(:render).with(foo_stub)

            render_inline(component)
          end
        end

        describe "and populate_with_defaults is false" do
          let(:populate_with_defaults) { false }

          it "does not send a value" do
            Edition::Details::Fields::StringComponent.expects(:new).with(
              has_entries(field: foo_field),
              Not(has_entries(value: anything)),
            ).returns(foo_stub)

            component.expects(:render).with(foo_stub)

            render_inline(component)
          end
        end
      end
    end
  end
end
