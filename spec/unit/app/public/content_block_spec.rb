RSpec.describe ContentBlock do
  describe ".from_content_id_alias" do
    it "returns a content block object" do
      document = build(:document)
      edition = build(:edition, document: document)
      schema = build(:schema)

      expect(Document).to receive(:find).with(document.content_id_alias).and_return(document)
      expect(document).to receive(:most_recent_edition).and_return(edition)
      expect(document).to receive(:schema).and_return(schema)

      content_block = ContentBlock.from_content_id_alias(document.content_id_alias)

      expect(content_block.title).to eq(edition.title)
      expect(content_block.block_type).to eq(schema.name)
    end
  end
end
