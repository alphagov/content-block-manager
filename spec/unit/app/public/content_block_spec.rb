RSpec.describe ContentBlock do
  let(:document) { build(:document) }
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
  it { should delegate_method(:lead_organisation).to(:edition) }
  it { should delegate_method(:render).to(:edition) }
  it { should delegate_method(:schema).to(:document) }
  it { should delegate_method(:embed_code).to(:document) }
  it { should delegate_method(:formats).to(:schema) }

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

  describe ".from_embed_code" do
    let(:document) do
      build(:document, :time_period, content_id_alias: "tax-year").tap do |built_document|
        built_document.embed_code = built_document.built_embed_code
      end
    end
    let(:published_edition) { build(:edition, document: document) }
    let(:valid_format) { document.schema.formats.first }
    let(:valid_field_path) { document.schema.fields.first.name }

    before do
      allow(Document).to receive(:find_by).with(embed_code: document.embed_code).and_return(document)
      allow(document).to receive(:latest_published_edition).and_return(published_edition)
    end

    context "when the embed code is valid" do
      it "returns a content block wrapping the published edition of the matching document" do
        content_block = ContentBlock.from_embed_code(document.embed_code)
        expect(content_block.id).to eq(published_edition.id)
      end
    end

    context "when the embed code includes a format segment" do
      it "returns a content block wrapping the published edition of the matching document" do
        expect(valid_format).to be_present
        embed_code_with_format = document.embed_code_for_format(valid_format)
        content_block = ContentBlock.from_embed_code(embed_code_with_format)
        expect(content_block.id).to eq(published_edition.id)
      end
    end

    context "when the embed code includes a path segment" do
      it "returns a content block wrapping the published edition of the matching document" do
        expect(valid_field_path).to be_present
        embed_code_with_path = document.embed_code_for_field(valid_field_path)
        content_block = ContentBlock.from_embed_code(embed_code_with_path)
        expect(content_block.id).to eq(published_edition.id)
      end
    end

    context "when no embed code is given" do
      it "handles a null embed code gracefully" do
        expect(ContentBlock.from_embed_code(nil)).to be_nil
      end
    end

    context "when an integer is given" do
      before do
        allow(Document).to receive(:find_by).with(embed_code: "666").and_return(nil)
      end

      it "returns nil" do
        expect(ContentBlock.from_embed_code(666)).to be_nil
      end
    end
  end

  describe "#embeddable_as_block?" do
    before do
      allow(document).to receive(:schema).and_return(schema)
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
