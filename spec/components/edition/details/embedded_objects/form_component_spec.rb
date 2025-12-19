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
      a_hash_including(field: foo_field),
    ).and_return(foo_stub)

    allow(Edition::Details::Fields::StringComponent).to receive(:new).with(
      a_hash_including(field: bar_field),
    ).and_return(bar_stub)

    allow(Edition::Details::Fields::EnumComponent).to receive(:new).with(
      a_hash_including(field: enum_field),
    ).and_return(enum_stub)

    allow(Edition::Details::Fields::TextareaComponent).to receive(:new).with(
      a_hash_including(field: textarea_field),
    ).and_return(textarea_stub)

    allow(Edition::Details::Fields::BooleanComponent).to receive(:new).with(
      a_hash_including(field: boolean_field),
    ).and_return(boolean_stub)

    allow(component).to receive(:render).with(anything)
  end

  it "renders fields for each property" do
    render_inline(component)

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      edition:,
      field: foo_field,
      subschema:,
      schema:,
    )

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      edition:,
      field: bar_field,
      subschema:,
      schema:,
    )

    expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
      edition:,
      field: enum_field,
      subschema:,
      value: "some value",
      schema:,
    )

    expect(Edition::Details::Fields::TextareaComponent).to have_received(:new).with(
      edition:,
      field: textarea_field,
      subschema:,
      schema:,
    )

    expect(Edition::Details::Fields::BooleanComponent).to have_received(:new).with(
      edition:,
      field: boolean_field,
      subschema:,
      schema:,
    )

    expect(component).to have_received(:render).with(foo_stub)
    expect(component).to have_received(:render).with(bar_stub)
    expect(component).to have_received(:render).with(enum_stub)
    expect(component).to have_received(:render).with(textarea_stub)
    expect(component).to have_received(:render).with(boolean_stub)
  end

  describe "when params are present" do
    let(:params) { { "foo" => "something" } }

    it "sends the value of a field if present in the params argument" do
      render_inline(component)

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        a_hash_including(field: foo_field, value: "something"),
      )
    end
  end

  describe "when `object_title` is provided" do
    let(:object_title) { "something" }

    it "sends the subschema's block_type as an `object_title` if provided" do
      render_inline(component)

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        a_hash_including(field: foo_field, object_title:),
      )

      expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
        a_hash_including(field: bar_field, object_title:),
      )

      expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
        a_hash_including(field: enum_field, object_title:),
      )

      expect(Edition::Details::Fields::TextareaComponent).to have_received(:new).with(
        a_hash_including(field: textarea_field, object_title:),
      )

      expect(Edition::Details::Fields::BooleanComponent).to have_received(:new).with(
        a_hash_including(field: boolean_field, object_title:),
      )
    end
  end

  describe "value" do
    before do
      allow(foo_field).to receive(:default_value).and_return(default_value)
    end

    describe "when a default value is available for a field" do
      let(:default_value) { "default value" }

      describe "and no value is present in the params" do
        let(:params) { {} }

        describe "and populate_with_defaults is true" do
          let(:populate_with_defaults) { true }

          it "sends the default value" do
            render_inline(component)

            expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
              a_hash_including(field: foo_field, value: default_value),
            )
          end
        end

        describe "and populate_with_defaults is false" do
          let(:populate_with_defaults) { false }

          it "does not send the default value" do
            render_inline(component)

            expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
              a_hash_including(field: foo_field),
            ) do |args|
              expect(args).not_to have_key(:value)
            end
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
            render_inline(component)

            expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
              a_hash_including(field: foo_field),
            ) do |args|
              expect(args).not_to have_key(:value)
            end
          end
        end

        describe "and populate_with_defaults is false" do
          let(:populate_with_defaults) { false }

          it "does not send a value" do
            render_inline(component)

            expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
              a_hash_including(field: foo_field),
            ) do |args|
              expect(args).not_to have_key(:value)
            end
          end
        end
      end
    end
  end
end
