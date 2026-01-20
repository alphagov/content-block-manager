RSpec.describe ContentBlock do
  let(:document) { build(:document, schema: schema) }
  let(:edition) { build(:edition, document: document) }
  let(:schema) { build(:schema) }

  let(:content_block) { ContentBlock.new(edition) }

  subject { content_block }

  it { should delegate_method(:id).to(:edition) }
  it { should delegate_method(:title).to(:edition) }
  it { should delegate_method(:state).to(:edition) }
  it { should delegate_method(:details).to(:edition) }
  it { should delegate_method(:document).to(:edition) }
  it { should delegate_method(:auth_bypass_id).to(:edition) }
  it { should delegate_method(:content_id).to(:edition) }
  it { should delegate_method(:render).to(:edition) }
  it { should delegate_method(:schema).to(:document) }

  describe ".from_content_id_alias" do
    it "returns a content block object" do
      allow(Document).to receive(:find).with(document.content_id_alias).and_return(document)
      allow(document).to receive(:most_recent_edition).and_return(edition)
      allow(ContentBlock).to receive(:new).with(edition).and_return(content_block)

      expect(ContentBlock.from_content_id_alias(document.content_id_alias)).to eq(content_block)
    end
  end

  describe ".from_edition_id" do
    it "returns a content block object" do
      allow(Edition).to receive(:find).with(edition.id).and_return(edition)
      allow(ContentBlock).to receive(:new).with(edition).and_return(content_block)

      expect(ContentBlock.from_edition_id(edition.id)).to eq(content_block)
    end
  end

  describe "#embeddable_as_block?" do
    before do
      allow(schema).to receive(:embeddable_as_block?).and_return(embeddable_as_block)
    end

    context "when the schema is embeddable_as_block" do
      let(:embeddable_as_block) { true }

      it "returns true" do
        expect(content_block.embeddable_as_block?).to be(true)
      end
    end

    context "when the schema is not embeddable_as_block" do
      let(:embeddable_as_block) { false }

      it "returns false" do
        expect(content_block.embeddable_as_block?).to be(false)
      end
    end
  end

  describe "#published_block" do
    let(:published_edition) { build(:edition, document: document) }
    let(:published_content_block) { build(:content_block) }

    before do
      allow(ContentBlock).to receive(:new).and_call_original

      allow(document).to receive(:latest_published_edition).and_return(published_edition)
      allow(ContentBlock).to receive(:new).with(published_edition).and_return(published_content_block)
    end

    it "returns the latest published edition from the edition's document" do
      expect(content_block.published_block).to eq(published_content_block)
    end

    context "when a published_content_block does not exist" do
      let(:published_content_block) { nil }

      it "returns nil" do
        expect(content_block.published_block).to be_nil
      end
    end
  end
end
