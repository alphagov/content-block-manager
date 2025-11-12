RSpec.describe Document::Show::EmbeddedObjects::MetadataComponent, type: :component do
  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end

  let(:schema_name) { "schema" }
  let(:object_type) { "object" }

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => properties,
        },
      },
    }
  end

  let(:properties) do
    {
      "foo" => {
        "type" => "string",
      },
      "fizz" => {
        "type" => "string",
      },
    }
  end

  let(:schema_id) { "bar" }

  let(:parent_schema_id) { "parent_schema_id" }

  let(:schema) do
    Schema::EmbeddedSchema.new(schema_id, body, parent_schema_id)
  end

  let(:schema_config) do
    {}
  end

  let(:component) do
    described_class.new(
      items:,
      schema_name:,
      object_type:,
      schema:,
    )
  end

  before do
    allow(schema).to receive(:config).and_return(schema_config)
  end

  context "when NO field order is defined" do
    it "renders a summary list with the expected attributes with no field ordering" do
      expect(component).to receive(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo",
              value: "bar",
            },
            {
              field: "Fizz",
              value: "buzz",
            },
          ],
        }
      ).and_return("STUB_RESPONSE")

      render_inline component

      expect(page).to have_text "STUB_RESPONSE"
    end

    context "when nested fields exist" do
      let(:items) do
        {
          "foo" => "bar",
          "nested" => {
            "field" => "item",
          },
        }
      end

      it "supports nested fields" do
        expect(component).to receive(:render).with(
          "govuk_publishing_components/components/summary_list", {
            items: [
              {
                field: "Foo",
                value: "bar",
              },
              {
                field: "Nested",
                value: { "field" => "item" },
              },
            ],
          }
        ).and_return("STUB_RESPONSE")

        render_inline component

        expect(page).to have_text "STUB_RESPONSE"
      end
    end
  end

  context "when a field order IS defined" do
    let(:schema_config) do
      {
        "field_order" => %w[fizz foo],
      }
    end

    it "renders a summary list with the defined field ordering (case insensitive)" do
      expect(component).to receive(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Fizz",
              value: "buzz",
            },
            {
              field: "Foo",
              value: "bar",
            },
          ],
        }
      ).and_return("STUB_RESPONSE")

      render_inline component

      expect(page).to have_text "STUB_RESPONSE"
    end
  end

  describe "when there is a translated field label" do
    let(:helpers) { double }

    before do
      allow(component).to receive(:helpers).and_return(helpers)
    end

    it "uses translated label" do
      expect(helpers).to receive(:humanized_label)
               .with(schema_name:, relative_key: "foo", root_object: object_type)
               .and_return("Foo translated")

      expect(helpers).to receive(:humanized_label)
               .with(schema_name:, relative_key: "fizz", root_object: object_type)
               .and_return("Fizz translated")

      expect(helpers).to receive(:translated_value)
               .with("foo", "bar")
               .and_return("bar")

      expect(helpers).to receive(:translated_value)
               .with("fizz", "buzz")
               .and_return("buzz")

      expect(component).to receive(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo translated",
              value: "bar",
            },
            {
              field: "Fizz translated",
              value: "buzz",
            },
          ],
        }
      ).and_return("STUB_RESPONSE")

      render_inline component

      expect(page).to have_text "STUB_RESPONSE"
    end
  end

  describe "when there is a translated field value" do
    let(:helpers) { double }

    before do
      allow(component).to receive(:helpers).and_return(helpers)
    end

    it "uses translated label" do
      expect(helpers).to receive(:humanized_label)
               .with(schema_name:, relative_key: "foo", root_object: object_type)
               .and_return("Foo")

      expect(helpers).to receive(:humanized_label)
               .with(schema_name:, relative_key: "fizz", root_object: object_type)
               .and_return("Fizz")

      expect(helpers).to receive(:translated_value)
               .with("foo", "bar")
               .and_return("Bar translated")

      expect(helpers).to receive(:translated_value)
               .with("fizz", "buzz")
               .and_return("Buzz translated")

      expect(component).to receive(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo",
              value: "Bar translated",
            },
            {
              field: "Fizz",
              value: "Buzz translated",
            },
          ],
        }
      ).and_return("STUB_RESPONSE")

      render_inline component

      expect(page).to have_text "STUB_RESPONSE"
    end
  end
end
