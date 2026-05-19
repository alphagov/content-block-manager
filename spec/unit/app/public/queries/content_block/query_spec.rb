RSpec.describe ContentBlock::Query do
  describe ".call" do
    it "returns one content block per document" do
      doc_a = create(:document)
      create(:edition, :published, document: doc_a, updated_at: 2.days.ago, title: "Doc A old edition")
      create(:edition, :published, document: doc_a, updated_at: 1.day.ago, title: "Doc A new edition")

      doc_b = create(:document)
      create(:edition, :published, document: doc_b, updated_at: Time.current, title: "Doc B new edition")

      excluded_document = create(:document)
      create(:edition, :draft, document: excluded_document, updated_at: Time.current)

      result = described_class.call

      expect(result).to all(be_a(ContentBlock))

      expect(result.size).to eq(2)
      expect(result.first.title).to eq("Doc A new edition")
      expect(result.second.title).to eq("Doc B new edition")
    end
  end
end
