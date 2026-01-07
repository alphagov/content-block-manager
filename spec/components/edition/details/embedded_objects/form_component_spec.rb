RSpec.describe Edition::Details::EmbeddedObjects::FormComponent, type: :component do
  let(:edition) { build(:edition) }

  let(:block_type) { "some_object" }
  let(:subschema) { build(:schema, block_type:) }

  let(:foo_field) { build(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { build(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:enum_field) { build(:field, name: "enum", component_name: "enum", enum_values: ["some value", "another value"], default_value: "some value", data_attributes: nil) }
  let(:textarea_field) { build(:field, name: "enum", component_name: "textarea", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:boolean_field) { build(:field, name: "boolean", component_name: "boolean", enum_values: nil, default_value: nil, data_attributes: nil) }

  let(:foo_stub) { double("string_component") }
  let(:bar_stub) { double("string_component") }
  let(:enum_stub) { double("enum_component") }
  let(:textarea_stub) { double("textarea_component") }
  let(:boolean_stub) { double("boolean_component") }

  let(:schema) { double(:schema) }

  let(:params) { nil }
  let(:populate_with_defaults) { true }
  let(:object_title) { nil }

  let(:component) do
    described_class.new(
      edition:,
      subschema:,
      schema:,
      params:,
      populate_with_defaults:,
      object_title:,
    )
  end

  before do
    allow(subschema).to receive(:fields).and_return([foo_field, bar_field, enum_field, textarea_field, boolean_field])

    allow(Edition::Details::Fields::StringComponent).to receive(:new).with(
      have_attributes(field: foo_field),
    ).and_return(foo_stub)

    allow(Edition::Details::Fields::StringComponent).to receive(:new).with(
      have_attributes(field: bar_field),
    ).and_return(bar_stub)

    allow(Edition::Details::Fields::EnumComponent).to receive(:new).with(
      have_attributes(field: enum_field),
    ).and_return(enum_stub)

    allow(Edition::Details::Fields::TextareaComponent).to receive(:new).with(
      have_attributes(field: textarea_field),
    ).and_return(textarea_stub)

    allow(Edition::Details::Fields::BooleanComponent).to receive(:new).with(
      have_attributes(field: boolean_field),
    ).and_return(boolean_stub)

    allow(component).to receive(:render).with(anything)
  end

  it "renders fields for each property" do
    render_inline(component)

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      have_attributes(
        edition:,
        field: foo_field,
        subschema:,
        schema:,
        populate_with_defaults:,
      ),
    )

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      have_attributes(
        edition:,
        field: bar_field,
        subschema:,
        schema:,
        populate_with_defaults:,
      ),
    )

    expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
      have_attributes(
        edition:,
        field: enum_field,
        subschema:,
        schema:,
        populate_with_defaults:,
      ),
    )

    expect(Edition::Details::Fields::TextareaComponent).to have_received(:new).with(
      have_attributes(
        edition:,
        field: textarea_field,
        subschema:,
        schema:,
        populate_with_defaults:,
      ),
    )

    expect(Edition::Details::Fields::BooleanComponent).to have_received(:new).with(
      have_attributes(
        edition:,
        field: boolean_field,
        subschema:,
        schema:,
        populate_with_defaults:,
      ),
    )

    expect(component).to have_received(:render).with(foo_stub)
    expect(component).to have_received(:render).with(bar_stub)
    expect(component).to have_received(:render).with(enum_stub)
    expect(component).to have_received(:render).with(textarea_stub)
    expect(component).to have_received(:render).with(boolean_stub)
  end

  describe "when `object_title` is provided" do
    let(:object_title) { "something" }

    it "sends the subschema's block_type as an `object_title` if provided" do
      render_inline(component)

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        have_attributes(field: foo_field, object_title:),
      )

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        have_attributes(field: bar_field, object_title:),
      )

      expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
        have_attributes(field: enum_field, object_title:),
      )

      expect(Edition::Details::Fields::TextareaComponent).to have_received(:new).with(
        have_attributes(field: textarea_field, object_title:),
      )

      expect(Edition::Details::Fields::BooleanComponent).to have_received(:new).with(
        have_attributes(field: boolean_field, object_title:),
      )
    end
  end

  describe "when `params` are provided" do
    let(:params) { { foo: "bar" } }

    it "sends the params as details" do
      render_inline(component)

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        have_attributes(field: foo_field, details: params),
      )

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        have_attributes(field: bar_field, details: params),
      )

      expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
        have_attributes(field: enum_field, details: params),
      )

      expect(Edition::Details::Fields::TextareaComponent).to have_received(:new).with(
        have_attributes(field: textarea_field, details: params),
      )

      expect(Edition::Details::Fields::BooleanComponent).to have_received(:new).with(
        have_attributes(field: boolean_field, details: params),
      )
    end
  end
end
