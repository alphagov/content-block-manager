require "test_helper"

class Edition::Details::FormComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:body) do
    {
      "type" => "object",
      "required" => %w[foo bar],
      "additionalProperties" => false,
      "properties" => {
        "foo" => {
          "type" => "string",
        },
        "bar" => {
          "type" => "string",
        },
        "baz" => {
          "type" => "string",
          "enum" => %w[some enum],
        },
      },
    }
  end

  let(:edition) { build(:edition) }
  let(:schema) { build(:schema, body:) }

  let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:baz_field) { stub("field", name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: nil) }

  let(:foo_stub) { stub("string_component") }
  let(:bar_stub) { stub("string_component") }
  let(:baz_stub) { stub("enum_component") }

  let(:populate_with_defaults) { true }

  let(:component) do
    Edition::Details::FormComponent.new(
      edition:,
      schema:,
      populate_with_defaults:,
    )
  end

  before do
    schema.stubs(:fields).returns([foo_field, bar_field, baz_field])

    Edition::Details::Fields::StringComponent.stubs(:new).with(
      has_entries(field: foo_field),
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.stubs(:new).with(
      has_entries(field: bar_field),
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.stubs(:new).with(
      has_entries(field: baz_field),
    ).returns(baz_stub)

    component.expects(:render).with(foo_stub).returns("foo_stub")
    component.expects(:render).with(bar_stub).returns("bar_stub")
    component.expects(:render).with(baz_stub).returns("baz_stub")
  end

  it "renders fields for each property" do
    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: foo_field,
      schema:,
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.expects(:new).with(
      edition:,
      field: bar_field,
      schema:,
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.expects(:new).with(
      edition:,
      field: baz_field,
      schema:,
      enum: %w[some enum],
    ).returns(baz_stub)

    assert render_inline(component)
  end

  it "sends values to the field components when the block has them" do
    edition.details = {
      "foo" => "foo value",
      "bar" => "bar value",
      "baz" => "baz value",
    }

    Edition::Details::Fields::StringComponent.expects(:new).with(
      has_entries(field: foo_field, value: "foo value"),
    ).returns(foo_stub)

    Edition::Details::Fields::StringComponent.expects(:new).with(
      has_entries(field: bar_field, value: "bar value"),
    ).returns(bar_stub)

    Edition::Details::Fields::EnumComponent.expects(:new).with(
      has_entries(field: baz_field, value: "baz value"),
    ).returns(baz_stub)

    assert render_inline(component)
  end

  describe "when data_attributes are provided" do
    let(:foo_field) { stub("field", name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "foo" }) }
    let(:bar_field) { stub("field", name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "bar" }) }
    let(:baz_field) { stub("field", name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: { "field" => "baz" }) }

    it "renders inside a div with data attributes" do
      Edition::Details::Fields::StringComponent.expects(:new).with(
        has_entries(field: foo_field),
      ).returns(foo_stub)

      Edition::Details::Fields::StringComponent.expects(:new).with(
        has_entries(field: bar_field),
      ).returns(bar_stub)

      Edition::Details::Fields::EnumComponent.expects(:new).with(
        has_entries(field: baz_field),
      ).returns(baz_stub)

      render_inline(component)

      assert_selector "div[data-field='foo']" do |component|
        component.assert_text "foo_stub"
      end

      assert_selector "div[data-field='bar']" do |component|
        component.assert_text "bar_stub"
      end

      assert_selector "div[data-field='baz']" do |component|
        component.assert_text "baz_stub"
      end
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

            render_inline(component)
          end
        end
      end
    end
  end
end
