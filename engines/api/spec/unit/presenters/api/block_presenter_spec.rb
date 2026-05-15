RSpec.describe Api::BlockPresenter do
  describe ".present" do
    it "serializes a content block into the public API shape" do
      lead_org = build(:organisation)
      block = build(:content_block)
      allow(block).to receive(:lead_organisation).and_return(lead_org)

      result = described_class.present(block)

      expect(result).to include(
        title: block.title,
        block_type: block.block_type,
        state: "published",
        embed_code: block.embed_code,
        formats: block.formats,
      )

      expect(result[:organisation]).to eq(
        name: lead_org.name,
        content_id: lead_org.id,
      )
    end
  end

  describe ".present_collection" do
    it "serializes all blocks in order" do
      org1 = build(:organisation, name: "Org 1")
      org2 = build(:organisation, name: "Org 2")

      block1 = build(:content_block)
      block2 = build(:content_block)

      allow(block1).to receive(:lead_organisation).and_return(org1)
      allow(block2).to receive(:lead_organisation).and_return(org2)

      blocks = [block1, block2]

      result = described_class.present_collection(blocks)

      expect(result.size).to eq(2)
      expect(result[0][:title]).to eq(blocks[0].title)
      expect(result[1][:title]).to eq(blocks[1].title)

      expect(result[0][:organisation]).to eq(name: org1.name, content_id: org1.id)
      expect(result[1][:organisation]).to eq(name: org2.name, content_id: org2.id)
    end

    it "returns an empty array for no blocks" do
      expect(described_class.present_collection([])).to eq([])
    end
  end
end
