RSpec.describe BlockContent do
  let(:subschema) { build(:schema) }
  let(:schema) { build(:schema) }
  let(:document) { build(:document, schema:) }
  let(:display_fields) { %w[amount] }
  let(:edition) do
    build(:edition,
          document: document,
          details: {
            "content_block_block_type" => {
              "my_rate" => {
                "title" => "my title",
                "frequency" => "weekly",
                "amount" => "£1000",
              },
            },
          })
  end
  let(:content_block) { build(:content_block, schema: subschema, edition:) }
  let(:block_content) { described_class.new(content_block, subschema) }

  before do
    allow(schema).to receive(:subschema).with("content_block_block_type").and_return(subschema)
    allow(subschema).to receive(:block_display_fields).and_return(display_fields)
  end

  describe "#metadata" do
    it "should return the fields that are not defined as block-level (display) fields" do
      expect(block_content.metadata("my_rate")).to eq({ "frequency" => "weekly", "title" => "my title" })
    end

    context "when block is not defined" do
      let(:content_block) { nil }

      it "should return nil" do
        expect(block_content.metadata("my_rate")).to be_nil
      end
    end
  end

  describe "#fields" do
    it "should return the fields defined as block-level (display) fields" do
      expect(block_content.fields("my_rate")).to eq({ "amount" => "£1000" })
    end

    context "when block is not defined" do
      let(:content_block) { nil }

      it "should return nil" do
        expect(block_content.fields("my_rate")).to be_nil
      end
    end
  end
end
