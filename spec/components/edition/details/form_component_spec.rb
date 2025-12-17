RSpec.describe Edition::Details::FormComponent, type: :component do
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

  let(:foo_field) { build(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:bar_field) { build(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: nil) }
  let(:baz_field) { build(:field, name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: nil) }

  let(:foo_stub) { double("string_component") }
  let(:bar_stub) { double("string_component") }
  let(:baz_stub) { double("enum_component") }

  let(:populate_with_defaults) { true }

  let(:component) do
    described_class.new(
      edition:,
      schema:,
      populate_with_defaults:,
    )
  end

  before do
    allow(schema).to receive(:fields).and_return([foo_field, bar_field, baz_field])

    allow(Edition::Details::Fields::StringComponent).to receive(:new).with(
      a_hash_including(field: foo_field),
    ).and_return(foo_stub)

    allow(Edition::Details::Fields::StringComponent).to receive(:new).with(
      a_hash_including(field: bar_field),
    ).and_return(bar_stub)

    allow(Edition::Details::Fields::EnumComponent).to receive(:new).with(
      a_hash_including(field: baz_field),
    ).and_return(baz_stub)

    allow(component).to receive(:render).with(foo_stub).and_return("foo_stub")
    allow(component).to receive(:render).with(bar_stub).and_return("bar_stub")
    allow(component).to receive(:render).with(baz_stub).and_return("baz_stub")
  end

  it "renders fields for each property" do
    render_inline(component)

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      edition:,
      field: foo_field,
      schema:,
    )

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      edition:,
      field: bar_field,
      schema:,
    )

    expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
      edition:,
      field: baz_field,
      schema:,
    )
  end

  it "sends values to the field components when the block has them" do
    edition.details = {
      "foo" => "foo value",
      "bar" => "bar value",
      "baz" => "baz value",
    }

    render_inline(component)

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      a_hash_including(field: foo_field, value: "foo value"),
    )

    expect(Edition::Details::Fields::StringComponent).to have_received(:new).with(
      a_hash_including(field: bar_field, value: "bar value"),
    )

    expect(Edition::Details::Fields::EnumComponent).to have_received(:new).with(
      a_hash_including(field: baz_field, value: "baz value"),
    )
  end

  describe "when data_attributes are provided" do
    let(:foo_field) { build(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "foo" }) }
    let(:bar_field) { build(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, data_attributes: { "field" => "bar" }) }
    let(:baz_field) { build(:field, name: "baz", component_name: "enum", enum_values: %w[some enum], default_value: nil, data_attributes: { "field" => "baz" }) }

    it "renders inside a div with data attributes" do
      render_inline(component)

      expect(page).to have_css "div[data-field='foo']" do |component|
        expect(component).to have_text "foo_stub"
      end

      expect(page).to have_css "div[data-field='bar']" do |component|
        expect(component).to have_text "bar_stub"
      end

      expect(page).to have_css "div[data-field='baz']" do |component|
        expect(component).to have_text "baz_stub"
      end
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
