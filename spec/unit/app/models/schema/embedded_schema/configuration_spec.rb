RSpec.describe Schema::EmbeddedSchema::Configuration do
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

  describe "#embeddable_as_block?" do
    describe "when `x-embeddable-as-block` is set in the schema" do
      let(:body) do
        {
          "type" => "object",
          "patternProperties" => {
            "*" => {
              "type" => "object",
              "x-embeddable-as-block" => true,
              "properties" => properties,
            },
          },
        }
      end

      it "returns true" do
        expect(schema).to be_embeddable_as_block
      end
    end

    describe "when `x-embeddable-as-block` is not set in the schema" do
      let(:body) do
        {
          "type" => "object",
          "patternProperties" => {
            "*" => {
              "type" => "object",
              "x-embeddable-as-block" => false,
              "properties" => properties,
            },
          },
        }
      end

      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end

  describe "#group" do
    describe "when a group is given in the schema body" do
      let(:body) do
        {
          "type" => "object",
          "patternProperties" => {
            "*" => {
              "type" => "object",
              "x-group" => "a_group",
              "properties" => properties,
            },
          },
        }
      end

      it "returns the subschemas default name" do
        expect(schema.group).to eq("a_group")
      end
    end

    describe "when a group is not given in the schema body" do
      it "returns nil" do
        expect(schema.group).to be_nil
      end
    end
  end

  describe "#group_order" do
    describe "when set in the schema body" do
      let(:body) do
        {
          "type" => "object",
          "patternProperties" => {
            "*" => {
              "type" => "object",
              "x-group-order" => 12,
              "properties" => properties,
            },
          },
        }
      end

      it "returns the group order as an integer" do
        expect(12).to eq(schema.group_order)
      end
    end

    describe "when not set in the schema body" do
      it "returns infinity to put the item at the end of the group" do
        expect(Float::INFINITY).to eq(schema.group_order)
      end
    end
  end
end
