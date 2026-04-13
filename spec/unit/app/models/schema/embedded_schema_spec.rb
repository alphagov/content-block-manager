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
  let(:parent_schema) { double(:schema, id: "parent_schema_id") }
  let(:schema) { Schema::EmbeddedSchema.new(schema_id, body, parent_schema) }

  it "returns the subschema id" do
    expect(schema_id).to eq(schema.id)
  end

  describe "#relationship_type" do
    context "when subschema maps to parent 'one to one' (TimePeriod has_one #date_range) " \
              "i.e. WITHOUT the use of 'patternProperties'" do
      let(:subschema_id) { "date_range" }
      let(:parent_schema) { double(:schema, id: "time_period") }
      let(:subschema) { Schema::EmbeddedSchema.new(subschema_id, body, parent_schema) }
      let(:body) do
        {
          "type" => "object",
          "properties" => {
            "date_time" => {
              "type" => "object",
              "properties" => {
                "start" => {
                  "type" => "object",
                  "properties" => {
                    "date" => { "type" => "string" },
                    "time" => { "type" => "string" },
                  },
                },
                "end" => {
                  "type" => "object",
                  "properties" => {
                    "date" => { "type" => "string" },
                    "time" => { "type" => "string" },
                  },
                },
              },
            },
          },
        }
      end

      it "has a one-to-one relationship" do
        expect(subschema.relationship_type).to be_one_to_one
      end
    end

    context "when subschema maps to parent 'one to many' (Contact has many EmailAddresses) " \
              "i.e. WITH the use of 'patternProperties'" do
      let(:subschema_id) { "email" }
      let(:parent_schema) { double(:schema, id: "email_addresses") }
      let(:subschema) { Schema::EmbeddedSchema.new(subschema_id, body, parent_schema) }
      let(:body) do
        {
          "type" => "object",
          "patternProperties" => {
            "^[a-z0-9]+(?:-[a-z0-9]+)*$" => {
              "type" => "object",
              "properties" => {
                "body" => { "type" => "string" },
                "email_address" => { "type" => "string" },
              },
            },
          },
        }
      end

      it "has a one-to-many relationship" do
        expect(subschema.relationship_type).to be_one_to_many
      end
    end
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
            parent_schema.id => {
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
            parent_schema.id => {
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

  describe "when an subschema that is not used for a first-class embedded object is used" do
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

    it "returns the subschema id" do
      expect(schema.id).to eq(schema_id)
    end

    it "returns the fields" do
      expect(schema.fields.map(&:name)).to eq(%w[foo bar])
    end
  end

  describe "#embeddable_as_block?" do
    describe "when set in the config" do
      before do
        allow(Schema::EmbeddedSchema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              parent_schema.id => {
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
              parent_schema.id => {
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
              parent_schema.id => {
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
              parent_schema.id => {
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

  describe "#datetime_fields" do
    describe "when some fields have format set to date-time" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "start" => {
            "type" => "string",
            "format" => "date-time",
          },
          "end" => {
            "type" => "string",
            "format" => "date-time",
          },
          "description" => {
            "type" => "string",
          },
        }
      end

      it "returns only the datetime fields" do
        datetime_fields = schema.datetime_fields

        expect(datetime_fields.map(&:name)).to eq(%w[start end])
        expect(datetime_fields).to all(be_a(Schema::Field))
      end
    end

    describe "when no fields have format set to date-time" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "description" => {
            "type" => "string",
          },
        }
      end

      it "returns an empty array" do
        expect(schema.datetime_fields).to eq([])
      end
    end
  end

  describe "#permitted_params" do
    it "returns permitted params" do
      expect(schema.permitted_params).to eq(%w[title amount description frequency])
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
        expect(schema.permitted_params).to eq(["title", { "foo" => %w[my_string] }, "bar"])
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
        expect(schema.permitted_params).to eq(["title", { "foo" => %w[_destroy] }, { "bar" => %w[my_string _destroy] }])
      end
    end

    describe "when some fields have deeply nested fields" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "foo" => {
            "type" => "object",
            "properties" => {
              "my_object" => {
                "type" => "object",
                "properties" => {
                  "my_string" => {
                    "type" => "string",
                  },
                },
              },
            },
          },
          "bar" => {
            "type" => "string",
          },
        }
      end

      it "returns permitted params" do
        expect(schema.permitted_params).to eq([
          "title",
          { "foo" => [{ "my_object" => %w[my_string] }] },
          "bar",
        ])
      end
    end
  end
end
