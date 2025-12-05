RSpec.describe Schema::Field do
  let(:schema) { build(:schema) }
  let(:field) { Schema::Field.new("something", schema) }

  let(:config) { {} }
  let(:body) { {} }

  before do
    allow(schema).to receive(:config).and_return(config)
    allow(schema).to receive(:body).and_return(body)
  end

  it "returns the name when cast as a string" do
    expect(field.to_s).to eq("something")
  end

  describe "#component_name" do
    describe "when there is no custom component set" do
      describe "when the field is a string" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string" } } }
        end

        it "returns string" do
          expect(field.component_name).to eq("string")
        end
      end

      describe "when the field has enum values" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string", "enum" => %w[foo bar] } } }
        end

        it "returns enum" do
          expect(field.component_name).to eq("enum")
        end
      end
    end

    describe "when there is a custom component set" do
      let(:config) do
        { "fields" => { "something" => { "component" => "custom" } } }
      end

      it "returns the custom component name" do
        expect(field.component_name).to eq("custom")
      end
    end

    describe "when the field is an object" do
      let(:body) do
        { "properties" => { "something" => { "type" => "object" } } }
      end

      it "returns object" do
        expect(field.component_name).to eq("object")
      end
    end
  end

  describe "#enum_values" do
    describe "when the field has enum values" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "enum" => %w[foo bar] } } }
      end

      it "returns enum" do
        expect(field.enum_values).to eq(%w[foo bar])
      end
    end

    describe "when the field has no enum values" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string" } } }
      end

      it "returns enum" do
        expect(field.enum_values).to be_nil
      end
    end
  end

  describe "#default_value" do
    describe "when the field has a default value" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "default" => "bar" } } }
      end

      it "returns enum" do
        expect(field.default_value).to eq("bar")
      end
    end

    describe "when the field has no defaut value" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string" } } }
      end

      it "returns enum" do
        expect(field.default_value).to be_nil
      end
    end
  end

  describe "#nested fields" do
    describe "when there are no nested fields present" do
      it "returns nil" do
        expect(field.nested_fields).to be_nil
      end
    end

    describe "when there are nested fields present" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "object",
              "properties" => {
                "foo" => { "type" => "string" },
                "bar" => { "type" => "string", "enum" => %w[foo bar] },
              },
            },
          },
        }
      end

      it "returns nested fields" do
        nested_fields = field.nested_fields

        expect(2).to eq(nested_fields.count)

        expect("foo").to eq(nested_fields[0].name)
        expect("bar").to eq(nested_fields[1].name)

        expect("string").to eq(nested_fields[0].format)
        expect("string").to eq(nested_fields[1].format)

        expect(nested_fields[0].enum_values).to be_nil
        expect(%w[foo bar]).to eq(nested_fields[1].enum_values)
      end
    end
  end

  describe "nested_field(name)" do
    let(:body) do
      {
        "properties" => {
          "something" => {
            "type" => "object",
            "properties" => {
              "foo" => { "type" => "string" },
              "bar" => { "type" => "string", "enum" => %w[bat cat], "default" => "cat" },
            },
          },
        },
      }
    end

    context "when no name is given" do
      it "raises an error" do
        error = assert_raises(ArgumentError) do
          field.nested_field(nil)
        end
        expect(error.message).to eq("Provide the name of a nested field")
      end
    end

    context "when a valid name is given" do
      let(:expected_match) do
        Schema::Field::NestedField.new(
          name: "bar",
          format: "string",
          enum_values: %w[bat cat],
          default_value: "cat",
        )
      end

      it "returns the nested field with the matching name" do
        assert_equal(
          expected_match,
          field.nested_field("bar"),
        )
      end
    end

    context "when an unknown name is given" do
      it "returns nil" do
        assert_nil(field.nested_field("unknown_name"))
      end
    end
  end

  describe "#array_items" do
    describe "when there are no properties present" do
      it "returns nil" do
        expect(field.array_items).to be_nil
      end
    end

    describe "when there are properties present" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "array",
              "items" => {
                "properties" => {
                  "foo" => { "type" => "string" },
                  "bar" => { "type" => "string", "enum" => %w[foo bar] },
                },
              },
            },
          },
        }
      end

      it "returns the array items" do
        assert_equal field.array_items, {
          "properties" => {
            "foo" => { "type" => "string" },
            "bar" => { "type" => "string", "enum" => %w[foo bar] },
          },
        }
      end

      describe "when an order is specified" do
        let(:config) do
          {
            "field_order" => %w[bar foo],
          }
        end

        it "returns the array items with the specified order" do
          assert_equal field.array_items, {
            "properties" => {
              "bar" => { "type" => "string", "enum" => %w[foo bar] },
              "foo" => { "type" => "string" },
            },
          }
        end
      end

      describe "when the array type is a string" do
        let(:body) do
          {
            "properties" => {
              "something" => {
                "type" => "array",
                "items" => {
                  "type" => "string",
                },
              },
            },
          }
        end

        it "returns successfully" do
          expect({ "type" => "string" }).to eq(field.array_items)
        end
      end
    end
  end

  describe "#is_required?" do
    it "returns true when in the schema's required fields" do
      allow(schema).to receive(:required_fields).and_return(%w[something])

      expect(field.is_required?).to eq(true)
    end

    it "returns false when note in the schema's required fields" do
      allow(schema).to receive(:required_fields).and_return(%w[else])

      expect(field.is_required?).to eq(false)
    end
  end

  describe "#data_attributes" do
    describe "when a `data_attributes` config var is set" do
      let(:config) do
        { "fields" => { "something" => { "data_attributes" => { "foo" => "bar" } } } }
      end

      it "returns the data attributes" do
        expect({ "foo" => "bar" }).to eq(field.data_attributes)
      end
    end

    describe "when a `data_attributes` config var is not set" do
      it "returns an empty hash" do
        expect({}).to eq(field.data_attributes)
      end
    end
  end
end
