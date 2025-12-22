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

  describe "#component_class" do
    it "returns the class name for a component" do
      expect(field).to receive(:component_name).and_return("string")

      expect(field.component_class).to eq(Edition::Details::Fields::StringComponent)
    end

    it "throws an error if the component does not exist" do
      expect(field).to receive(:component_name).and_return("non_existent")

      expect { field.component_class }.to raise_error("Component Edition::Details::Fields::NonExistentComponent not found")
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

        expect(nested_fields.count).to eq(2)

        expect(nested_fields[0].name).to eq("foo")
        expect(nested_fields[0].format).to eq("string")
        expect(nested_fields[0].enum_values).to be_nil
        expect(nested_fields[0].name_attribute).to eq("edition[details][something][foo]")
        expect(nested_fields[0].id_attribute).to eq("edition_details_something_foo")

        expect(nested_fields[1].name).to eq("bar")
        expect(nested_fields[1].format).to eq("string")
        expect(nested_fields[1].enum_values).to eq(%w[foo bar])
        expect(nested_fields[1].name_attribute).to eq("edition[details][something][bar]")
        expect(nested_fields[1].id_attribute).to eq("edition_details_something_bar")
      end

      describe "when config is set for the nested fields" do
        let(:config) do
          {
            "fields" => {
              "something" => {
                "fields" => {
                  "foo" => {
                    "component" => "custom",
                  },
                  "bar" => {
                    "component" => "textarea",
                  },
                },
              },
            },
          }
        end

        it "returns config for each field" do
          nested_fields = field.nested_fields

          expect(nested_fields.count).to eq(2)

          expect(nested_fields[0].config).to eq({ "component" => "custom" })
          expect(nested_fields[1].config).to eq({ "component" => "textarea" })
        end
      end
    end

    describe "when there are nested fields present within an array" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "array",
              "items" => {
                "type" => "object",
                "properties" => {
                  "foo" => { "type" => "string" },
                  "bar" => { "type" => "string", "enum" => %w[foo bar] },
                },
              },
            },
          },
        }
      end

      it "returns nested fields" do
        nested_fields = field.nested_fields

        expect(nested_fields.count).to eq(2)

        expect(nested_fields[0].name).to eq("foo")
        expect(nested_fields[0].format).to eq("string")
        expect(nested_fields[0].enum_values).to be_nil
        expect(nested_fields[0].name_attribute).to eq("edition[details][something][][foo]")
        expect(nested_fields[0].id_attribute).to eq("edition_details_something_foo")

        expect(nested_fields[1].name).to eq("bar")
        expect(nested_fields[1].format).to eq("string")
        expect(nested_fields[1].enum_values).to eq(%w[foo bar])
        expect(nested_fields[1].name_attribute).to eq("edition[details][something][][bar]")
        expect(nested_fields[1].id_attribute).to eq("edition_details_something_bar")
      end

      describe "when config is set for the nested fields" do
        let(:config) do
          {
            "fields" => {
              "something" => {
                "fields" => {
                  "foo" => {
                    "component" => "custom",
                  },
                  "bar" => {
                    "component" => "textarea",
                  },
                },
              },
            },
          }
        end

        it "returns config for each field" do
          nested_fields = field.nested_fields

          expect(nested_fields.count).to eq(2)

          expect(nested_fields[0].config).to eq({ "component" => "custom" })
          expect(nested_fields[1].config).to eq({ "component" => "textarea" })
        end
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
      it "returns the nested field with the matching name" do
        nested_field = field.nested_field("bar")

        expect(nested_field.name).to eq("bar")
        expect(nested_field.format).to eq("string")
        expect(nested_field.enum_values).to eq(%w[bat cat])
        expect(nested_field.default_value).to eq("cat")
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

  context "when the schema does not have a parent" do
    describe "#name_attribute" do
      it "returns the field name" do
        expect(field.name_attribute).to eq("edition[details][something]")
      end
    end

    describe "#id_attribute" do
      it "returns the field id" do
        expect(field.id_attribute).to eq("edition_details_something")
      end
    end

    describe "#error_key" do
      it "returns the field id without the leading `edition`" do
        expect(field.error_key).to eq("details_something")
      end
    end

    describe "#translation_lookup_path" do
      it "returns an array with the field name" do
        expect(field.value_lookup_path).to eq(%w[something])
      end
    end
  end

  context "when the schema is an embedded schema" do
    let(:schema) { build(:embedded_schema, parent_schema: build(:schema), block_type: "embedded") }

    describe "#name_attribute" do
      it "returns the field name" do
        expect(field.name_attribute).to eq("edition[details][embedded][something]")
      end
    end

    describe "#id_attribute" do
      it "returns the field id" do
        expect(field.id_attribute).to eq("edition_details_embedded_something")
      end
    end

    describe "#error_key" do
      it "returns the field id without the leading `edition`" do
        expect(field.error_key).to eq("details_embedded_something")
      end
    end

    describe "#value_lookup_path" do
      it "returns an array with the field and schema name" do
        expect(field.value_lookup_path).to eq(%w[embedded something])
      end
    end

    context "when the field is an array" do
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

      describe "#name_attribute" do
        it "returns the field name" do
          expect(field.name_attribute).to eq("edition[details][embedded][something][]")
        end

        it "includes an index if present" do
          expect(field.name_attribute(1)).to eq("edition[details][embedded][something][1]")
        end
      end

      describe "#id_attribute" do
        it "returns the field id" do
          expect(field.id_attribute).to eq("edition_details_embedded_something")
        end

        it "includes an index if present" do
          expect(field.id_attribute(1)).to eq("edition_details_embedded_something_1")
        end
      end

      describe "#error_key" do
        it "returns the field id without the leading `edition`" do
          expect(field.error_key).to eq("details_embedded_something")
        end

        it "includes an index if present" do
          expect(field.error_key(1)).to eq("details_embedded_something_1")
        end
      end

      describe "#value_lookup_path" do
        it "returns an array with the field name, schema name and index" do
          expect(field.value_lookup_path(1)).to eq(["embedded", "something", 1])
        end
      end
    end
  end

  context "when the schema is deeply nested" do
    let(:root_schema) { build(:schema) }
    let(:parent_schema) { build(:embedded_schema, block_type: "level_1", parent_schema: root_schema) }
    let(:schema) { build(:embedded_schema, parent_schema: parent_schema, block_type: "level_2") }

    describe "#name_attribute" do
      it "returns the field name" do
        expect(field.name_attribute).to eq("edition[details][level_1][level_2][something]")
      end
    end

    describe "#id_attribute" do
      it "returns the field id" do
        expect(field.id_attribute).to eq("edition_details_level_1_level_2_something")
      end
    end

    describe "#error_key" do
      it "returns the field id without the leading `edition`" do
        expect(field.error_key).to eq("details_level_1_level_2_something")
      end
    end

    describe "#value_lookup_path" do
      it "returns an array with the field name and schemas" do
        expect(field.value_lookup_path).to eq(%w[level_1 level_2 something])
      end
    end

    context "when the parent schema is an array" do
      let(:schema) { build(:embedded_schema, parent_schema: parent_schema, block_type: "level_2", is_array: true) }

      describe "#name_attribute" do
        it "returns the field name" do
          expect(field.name_attribute).to eq("edition[details][level_1][level_2][][something]")
        end

        it "includes an index if present" do
          expect(field.name_attribute(1)).to eq("edition[details][level_1][level_2][1][something]")
        end
      end

      describe "#id_attribute" do
        it "returns the field id" do
          expect(field.id_attribute).to eq("edition_details_level_1_level_2_something")
        end

        it "includes an index if present" do
          expect(field.id_attribute(1)).to eq("edition_details_level_1_level_2_1_something")
        end
      end

      describe "#error_key" do
        it "returns the field id without the leading `edition`" do
          expect(field.error_key).to eq("details_level_1_level_2_something")
        end

        it "includes an index if present" do
          expect(field.error_key(1)).to eq("details_level_1_level_2_1_something")
        end
      end

      describe "#value_lookup_path" do
        it "returns an array with the 2 parent schema names, the index and the field name" do
          expect(field.value_lookup_path(1)).to eq(["level_1", "level_2", 1, "something"])
        end
      end
    end
  end

  describe "#hidden?" do
    describe "when a config var is set to hide the field" do
      let(:config) do
        { "fields" => { "something" => { Schema::Field::HIDDEN_FIELD_PROPERTY_KEY => true } } }
      end

      it "returns true" do
        expect(field.hidden?).to be_truthy
      end
    end

    describe "when a config var is not set" do
      it "returns false" do
        expect(field.hidden?).to be_falsey
      end
    end
  end

  describe "#govspeak_enabled?" do
    describe "when a config var is set to enable Govspeak" do
      let(:config) do
        { "fields" => { "something" => { Schema::Field::GOVSPEAK_ENABLED_PROPERTY_KEY => true } } }
      end

      it "returns true" do
        expect(field.govspeak_enabled?).to be_truthy
      end
    end

    describe "when a config var is not set" do
      it "returns false" do
        expect(field.govspeak_enabled?).to be_falsey
      end
    end
  end

  describe "#show_field" do
    let(:body) do
      {
        "properties" => {
          "something" => {
            "type" => "object",
            "properties" => {
              "show_field" => { "type" => "boolean" },
              "text" => { "type" => "string" },
            },
          },
        },
      }
    end

    context "when the field does not have a show_field_name set in the config" do
      let(:config) do
        { "fields" => { "something" => {} } }
      end

      it "returns the field to conditionally reveal an object" do
        show_field = field.show_field

        expect(show_field).to be_nil
      end
    end

    context "when the field does have a show_field_name set in the config" do
      let(:config) do
        { "fields" => { "something" => { "show_field_name" => "show_field" } } }
      end

      it "returns the field to conditionally reveal an object" do
        show_field = field.show_field

        expect(show_field).to_not be_nil
        expect(show_field.name).to eq("show_field")
      end
    end
  end
end
