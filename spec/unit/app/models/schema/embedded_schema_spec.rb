RSpec.describe Schema::EmbeddedSchema do
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
      "amount" => {
        "type" => "string",
      },
      "description" => {
        "type" => "string",
      },
      "frequency" => {
        "type" => "string",
      },
      "title" => {
        "type" => "string",
      },
    }
  end
  let(:schema_id) { "bar" }
  let(:parent_schema_id) { "parent_schema_id" }
  let(:schema) { Schema::EmbeddedSchema.new(schema_id, body, parent_schema_id) }

  it "returns the subschema id" do
    expect(schema_id).to eq(schema.id)
  end

  it "returns the fields" do
    expect(%w[title amount description frequency]).to eq(schema.fields.map(&:name))
  end

  describe "#group" do
    describe "when a group is given in config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({ "schemas" => {
            parent_schema_id => {
              "subschemas" => {
                "bar" => {
                  "group" => "a_group",
                },
              },
            },
          } })
      end

      it "returns the subschemas default name" do
        expect(schema.group).to eq("a_group")
      end
    end

    describe "when a group is not given in config" do
      it "returns nil" do
        expect(schema.group).to be_nil
      end
    end
  end

  describe "when an order is given in the config" do
    before do
      allow(Schema::EmbeddedSchema)
        .to receive(:schema_settings)
        .and_return({
          "schemas" => {
            parent_schema_id => {
              "subschemas" => {
                schema_id => {
                  "field_order" => %w[frequency amount description title],
                },
              },
            },
          },
        })
    end

    it "orders fields" do
      expect(%w[frequency amount description title]).to eq(schema.fields.map(&:name))
    end
  end

  describe "when no order is given" do
    before do
      allow(Schema)
        .to receive(:schema_settings)
        .and_return({})
    end

    it "prioritises the title" do
      expect(%w[title amount description frequency]).to eq(schema.fields.map(&:name))
    end
  end

  describe "when an invalid subschema is given" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "properties" => {
              "my_string" => {
                "type" => "string",
              },
              "something_else" => {
                "type" => "string",
              },
            },
          },
        },
      }
    end

    it "raises an error" do
      assert_raises ArgumentError, "Subschema `bar` is invalid" do
        schema
      end
    end
  end

  describe "#embeddable_as_block?" do
    describe "when set in the config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {
                    "embeddable_as_block" => true,
                  },
                },
              },
            },
          })
      end

      it "returns true" do
        expect(schema).to be_embeddable_as_block
      end
    end

    describe "when not set in the config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {},
                },
              },
            },
          })
      end

      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end

  describe "#group_order" do
    describe "when set in the config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {
                    "group_order" => "12",
                  },
                },
              },
            },
          })
      end

      it "returns the group order as an integer" do
        expect(12).to eq(schema.group_order)
      end
    end

    describe "when not set in the config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {},
                },
              },
            },
          })
      end

      it "returns infinity to put the item at the end of the group" do
        expect(Float::INFINITY).to eq(schema.group_order)
      end
    end
  end

  describe "#permitted_params" do
    it "returns permitted params" do
      expect(%w[title amount description frequency]).to eq(schema.permitted_params)
    end

    describe "when some fields have nested fields" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "foo" => {
            "type" => "object",
            "properties" => {
              "my_string" => {},
            },
          },
          "bar" => {
            "type" => "string",
          },
        }
      end

      it "returns permitted params" do
        expect(["title", { "foo" => %w[my_string] }, "bar"]).to eq(schema.permitted_params)
      end
    end

    describe "when some fields have an array type" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "foo" => {
            "type" => "array",
            "items" => {
              "type" => "string",
            },
          },
          "bar" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "properties" => {
                "my_string" => {},
              },
            },
          },
        }
      end

      it "returns permitted params" do
        expect(["title", { "foo" => %w[_destroy] }, { "bar" => %w[my_string _destroy] }]).to eq(schema.permitted_params)
      end
    end
  end

  describe "#govspeak_enabled?(field:)" do
    let(:body) do
      {
        "type" => "object",
        "patternProperties" => {
          "*" => {
            "type" => "object",
            "properties" => {},
          },
        },
      }
    end

    let(:subschema_id) { "subschema_id" }
    let(:parent_schema_id) { "parent_schema_id" }
    let(:schema) { Schema::EmbeddedSchema.new(subschema_id, body, parent_schema_id) }

    let(:config) do
      {
        "schemas" => {
          parent_schema_id => {
            "subschemas" => {
              subschema_id => {
                "fields" => {
                  "field_1" => {},
                  "field_2" => { "govspeak_enabled" => true },
                  "nested_object_1" => {
                    "fields" => {
                      "field_1" => {},
                      "field_2" => { "govspeak_enabled" => true },
                    },
                  },
                  "nested_object_2" => {
                    "fields" => {
                      "field_1" => { "govspeak_enabled" => true },
                      "field_2" => {},
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    before do
      allow(Schema::EmbeddedSchema)
        .to receive(:schema_settings)
        .and_return(config)
    end

    context "when a nested_object_key is given" do
      it "returns true if the given field in the nested object is declared govspeak_enabled" do
        assert(schema.govspeak_enabled?(nested_object_key: "nested_object_1", field_name: "field_2"))
      end

      it "returns false if the given field in the nested object is NOT govspeak_enabled" do
        assert_not(schema.govspeak_enabled?(nested_object_key: "nested_object_2", field_name: "field_2"))
      end
    end

    context "when a nested_object_key is NOT given" do
      it "returns true if the given field in the top-level properties is govspeak_enabled" do
        assert(schema.govspeak_enabled?(field_name: "field_2"))
      end

      it "returns false if the given field in the top-level properties is NOT govspeak_enabled" do
        assert_not(schema.govspeak_enabled?(field_name: "field_1"))
      end
    end
  end

  describe "#hidden_field?(field:)" do
    let(:body) do
      {
        "type" => "object",
        "patternProperties" => {
          "*" => {
            "type" => "object",
            "properties" => {},
          },
        },
      }
    end

    let(:subschema_id) { "subschema_id" }
    let(:parent_schema_id) { "parent_schema_id" }
    let(:schema) { Schema::EmbeddedSchema.new(subschema_id, body, parent_schema_id) }

    let(:config) do
      {
        "schemas" => {
          parent_schema_id => {
            "subschemas" => {
              subschema_id => {
                "fields" => {
                  "field_1" => {},
                  "field_2" => { "hidden_field" => true },
                  "nested_object_1" => {
                    "fields" => {
                      "field_1" => {},
                      "field_2" => { "hidden_field" => true },
                    },
                  },
                  "nested_object_2" => {
                    "fields" => {
                      "field_1" => { "hidden_field" => true },
                      "field_2" => {},
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    before do
      allow(Schema::EmbeddedSchema)
        .to receive(:schema_settings)
        .and_return(config)
    end

    context "when a nested_object_key is given" do
      it "returns true if the given field in the nested object is declared hidden_field" do
        assert(schema.hidden_field?(nested_object_key: "nested_object_1", field_name: "field_2"))
      end

      it "returns false if the given field in the nested object is NOT hidden_field" do
        assert_not(schema.hidden_field?(nested_object_key: "nested_object_2", field_name: "field_2"))
      end
    end

    context "when a nested_object_key is NOT given" do
      it "returns true if the given field in the top-level properties is hidden_field" do
        assert(schema.hidden_field?(field_name: "field_2"))
      end

      it "returns false if the given field in the top-level properties is NOT hidden_field" do
        assert_not(schema.hidden_field?(field_name: "field_1"))
      end
    end
  end
end
