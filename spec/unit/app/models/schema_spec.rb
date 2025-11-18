RSpec.describe Schema do
  let(:body) { { "properties" => { "foo" => {}, "bar" => {}, "title" => {} } } }
  let(:schema) { build(:schema, :pension, body:) }

  it "generates a human-readable name" do
    expect("Pension").to eq(schema.name)
  end

  it "generates a parameterized name for use in URLs" do
    expect("pension").to eq(schema.parameter)
  end

  it "returns a block type" do
    expect("pension").to eq(schema.block_type)
  end

  describe "#fields" do
    describe "when an order is not given in the config" do
      it "prioritises the title" do
        expect(%w[title foo bar]).to eq(schema.fields.map(&:name))
      end
    end

    describe "when an order is given in the config" do
      before do
        allow(Schema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              "content_block_pension" => {
                "field_order" => %w[bar title foo],
              },
            },
          })
      end

      it "orders fields" do
        expect(%w[bar title foo]).to eq(schema.fields.map(&:name))
      end

      describe "when a field is missing from the order" do
        before do
          allow(Schema)
            .to receive(:schema_settings)
            .and_return({
              "schemas" => {
                "content_block_pension" => {
                  "field_order" => %w[bar foo],
                },
              },
            })
        end

        it "puts the missing field at the end" do
          expect(%w[bar foo title]).to eq(schema.fields.map(&:name))
        end
      end
    end
  end

  describe "#govspeak_enabled?(field_name:)" do
    let(:schema_id) { "content_block_contact" }

    let(:body) do
      {
        "type" => "object",
        "properties" => {},
      }
    end

    let(:schema) { Schema.new(schema_id, body) }

    let(:config) do
      {
        "schemas" => {
          schema_id => {
            "fields" => {
              "field_1" => {},
              "field_2" => { "govspeak_enabled" => true },
            },
          },
        },
      }
    end

    before do
      allow(Schema)
        .to receive(:schema_settings)
        .and_return(config)
    end

    it "returns true if the given field is govspeak_enabled" do
      assert(schema.govspeak_enabled?(field_name: "field_2"))
    end

    it "returns false if the given field is NOT govspeak_enabled" do
      assert_not(schema.govspeak_enabled?(field_name: "field_1"))
    end
  end

  describe "#hidden_field?(field_name:)" do
    let(:schema_id) { "content_block_contact" }

    let(:body) do
      {
        "type" => "object",
        "properties" => {},
      }
    end

    let(:schema) { Schema.new(schema_id, body) }

    let(:config) do
      {
        "schemas" => {
          schema_id => {
            "fields" => {
              "field_1" => {},
              "field_2" => { "hidden_field" => true },
            },
          },
        },
      }
    end

    before do
      allow(Schema)
        .to receive(:schema_settings)
        .and_return(config)
    end

    it "returns true if the given field is set as hidden_field" do
      assert(schema.hidden_field?(field_name: "field_2"))
    end

    it "returns false if the given field is NOT set as hidden_field" do
      assert_not(schema.hidden_field?(field_name: "field_1"))
    end
  end

  describe "#required_fields" do
    describe "when there are no required fields" do
      it "returns an empty array" do
        expect(schema.required_fields).to eq([])
      end
    end

    describe "when there are required fields" do
      it "returns them as an array" do
        body["required"] = %w[foo]
        expect(schema.required_fields).to eq(%w[foo])
      end
    end
  end

  describe "when a schema has embedded objects" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "patternProperties" => {
              "*" => {
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
          },
        },
      }
    end

    describe "#fields" do
      it "removes object fields" do
        expect(%w[foo]).to eq(schema.fields.map(&:name))
      end
    end

    describe "#subschemas" do
      it "returns subschemas" do
        subschemas = schema.subschemas

        expect(%w[bar]).to eq(subschemas.map(&:id))
      end
    end
  end

  describe "when a schema includes an order property" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "order" => {
            "type" => "array",
          },
        },
      }
    end

    describe "#fields" do
      it "excludes the order field" do
        expect(%w[foo]).to eq(schema.fields.map(&:name))
      end
    end
  end

  describe ".permitted_params" do
    it "returns permitted params" do
      expect(%w[title foo bar]).to eq(schema.permitted_params)
    end
  end

  describe ".valid_schemas" do
    it "returns the contents of the VALID_SCHEMA constant" do
      assert_equal Schema.valid_schemas, %w[
        pension
        contact
      ]
    end

    describe "when the show_all_content_block_types feature flag is turned off" do
      before do
        allow(Flipflop).to receive(:show_all_content_block_types?).and_return(false)
      end

      it "only returns pensions" do
        expect(%w[pension]).to eq(Schema.valid_schemas)
      end
    end
  end

  describe ".all" do
    before(:each) do
      allow(Services.publishing_api).to receive(:get_schemas).once.and_return({
        "something" => {},
        "something_else" => {},
        "content_block_foo" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "foo_field" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_bar" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "bar_field" => {
                  "type" => "string",
                },
                "bar_field2" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_invalid" => {},
      })
      allow(Schema).to receive(:is_valid_schema?).with(anything).and_return(false)
      allow(Schema).to receive(:is_valid_schema?).with(satisfy { |arg| %w[content_block_foo content_block_bar].include?(arg) }).and_return(true)
    end

    it "returns a list of schemas with the content block prefix" do
      schemas = Schema.all
      expect(%w[content_block_foo content_block_bar]).to eq(schemas.map(&:id))
      fields = schemas.map(&:fields)
      expect(%w[foo_field]).to eq(fields.[](0).map(&:name))
      expect(%w[bar_field bar_field2]).to eq(fields.[](1).map(&:name))
    end

    it "memoizes the result" do
      # Mocha won't let us assert how many times something was called, so
      # given that we only expect Publishing API to be called once, let's
      # call our service method twice and assert that no errors were raised
      assert_nothing_raised do
        2.times { Schema.all }
      end
    end
  end

  describe ".find_by_block_type" do
    let(:block_type) { "pension" }
    let(:body) do
      {
        "properties" => {
          "email_address" => {
            "type" => "string",
            "format" => "email",
          },
        },
      }
    end

    before do
      allow(Schema).to receive(:all).and_return([
        build(:schema, block_type:, body:),
        build(:schema, block_type: "something_else", body: {}),
      ])
    end

    it "it returns the schema when the block_type is valid" do
      schema = Schema.find_by_block_type(block_type)

      expect("content_block_#{block_type}").to eq(schema.id)
      expect(block_type).to eq(schema.block_type)
      expect(%w[email_address]).to eq(schema.fields.map(&:name))
    end

    it "it throws an error when the schema  cannot be found for the block type" do
      block_type = "other_thing"

      assert_raises ArgumentError, "Cannot find schema for #{block_type}" do
        Schema.find_by_block_type(block_type)
      end
    end
  end

  describe ".is_valid_schema?" do
    it "returns true when the schema has correct prefix/suffix" do
      Schema.valid_schemas.each do |schema|
        schema_name = "#{Schema::SCHEMA_PREFIX}_#{schema}"
        expect(Schema.is_valid_schema?(schema_name)).to be
      end
    end

    it "returns false when given an invalid schema" do
      schema_name = "something_else"
      expect(false).to eq(Schema.is_valid_schema?(schema_name))
    end

    it "returns false when the schema has correct prefix but a suffix that is not valid" do
      schema_name = "#{Schema::SCHEMA_PREFIX}_something"
      expect(false).to eq(Schema.is_valid_schema?(schema_name))
    end
  end

  describe ".schema_settings" do
    let(:stub_schema) { double("schema_settings") }

    before do
      expect(YAML).to receive(:load_file)
          .with(Schema::CONFIG_PATH)
          .and_return(stub_schema)

      # This removes any memoized schema_settings, so we can be sure the double gets returned
      Schema.instance_variable_set("@schema_settings", nil)
    end

    after do
      # Make sure we remove the stubbed schema_settings response after the tests in this block run
      Schema.instance_variable_set("@schema_settings", nil)
    end

    it "should return the schema settings" do
      expect(stub_schema).to eq(Schema.schema_settings)
    end
  end

  describe "when a schema has embedded objects" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "patternProperties" => {
              "*" => {
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
          },
        },
      }
    end

    describe "#fields" do
      it "removes object fields" do
        expect(%w[foo]).to eq(schema.fields.map(&:name))
      end
    end
  end

  describe "#block_display_fields" do
    describe "when config exists for a schema" do
      before do
        allow(Schema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              schema.id => {
                "block_display_fields" => %w[something else],
              },
            },
          })
      end

      it "returns the config values" do
        expect(%w[something else]).to eq(schema.block_display_fields)
      end
    end

    describe "when config does not exist for a schema" do
      before do
        allow(Schema)
          .to receive(:schema_settings)
          .and_return({})
      end

      it "returns an empty array" do
        expect([]).to eq(schema.block_display_fields)
      end
    end
  end

  describe "#subschemas_for_group" do
    let(:group_1_subschemas) do
      [
        double(:subschema, group: "group_1", group_order: 2),
        double(:subschema, group: "group_1", group_order: 1),
      ]
    end

    let(:subschemas) do
      [
        *group_1_subschemas,
        double(:subschema, group: nil),
        double(:subschema, group: nil),
      ]
    end

    before do
      allow(schema).to receive(:subschemas).and_return(subschemas)
    end

    it "returns subschemas for a group sorted by the group order" do
      expect([group_1_subschemas.[](1), group_1_subschemas.[](0)]).to eq(schema.subschemas_for_group("group_1"))
    end

    it "returns an empty array when no subschemas can be found" do
      expect([]).to eq(schema.subschemas_for_group("group_2"))
    end
  end

  describe "#embeddable_as_block?" do
    describe "when the embeddable_as_block config value is set" do
      before do
        allow(Schema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              schema.id => {
                "embeddable_as_block" => true,
              },
            },
          })
      end

      it "returns true" do
        expect(schema).to be_embeddable_as_block
      end
    end

    describe "when the embeddable_as_block config value is not set" do
      before do
        allow(Schema)
          .to receive(:schema_settings)
          .and_return({
            "schemas" => {
              schema.id => {},
            },
          })
      end

      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end
end
