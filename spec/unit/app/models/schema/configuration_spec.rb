RSpec.describe Schema::Configuration do
  let(:body) { { "properties" => { "foo" => {}, "bar" => {}, "title" => {} } } }
  let(:schema) { build(:schema, :pension, body:) }

  describe "#block_display_fields" do
    describe "when `x-block-display-fields` is set in the schema body" do
      let(:body) do
        {
          "x-block-display-fields" => %w[title description],
          "properties" => {
            "title" => {
              "type" => "string",
            },
            "description" => {
              "type" => "string",
            },
          },
        }
      end

      it "returns the block display fields from the JSON body" do
        expect(schema.block_display_fields).to eq(%w[title description])
      end
    end

    describe "when `x-block-display-fields` is not set in the schema body" do
      it "returns an empty array" do
        expect(schema.block_display_fields).to eq([])
      end
    end
  end

  describe "#embeddable_as_block?" do
    describe "when `x-embeddable-as-block` is set in the schema" do
      let(:body) do
        {
          "x-embeddable-as-block" => true,
          "properties" => {},
        }
      end

      it "returns true" do
        expect(schema).to be_embeddable_as_block
      end
    end

    describe "when `x-embeddable-as-block` is not set" do
      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end

  describe "#field_order" do
    describe "when `x-field-order` is set in the schema body" do
      let(:body) do
        {
          "x-field-order" => %w[foo bar title],
          "properties" => {
            "foo" => {
              "type" => "string",
            },
            "bar" => {
              "type" => "string",
            },
            "title" => {
              "type" => "string",
            },
          },
        }
      end

      it "returns the field order from the JSON body" do
        expect(schema.field_order).to eq(%w[foo bar title])
      end
    end

    describe "when `x-field-order` is not set in the schema body" do
      it "returns nil" do
        expect(schema.field_order).to be_nil
      end
    end
  end
end
