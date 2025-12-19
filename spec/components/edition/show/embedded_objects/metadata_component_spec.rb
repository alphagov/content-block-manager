RSpec.describe Edition::Show::EmbeddedObjects::MetadataComponent, type: :component do
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

  let(:parent_schema) { build(:schema) }
  let(:schema) do
    Schema::EmbeddedSchema.new(schema_id, body, parent_schema)
  end

  let(:schema_config) do
    {}
  end

  let(:component) do
    described_class.new(
      items:,
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

      let(:properties) do
        {
          "foo" => {
            "type" => "string",
          },
          "nested" => {
            "type" => "object",
            "properties" => {
              "field" => { "type" => "string" },
            },
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
end
