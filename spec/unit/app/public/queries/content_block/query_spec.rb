RSpec.describe ContentBlock::Query do
  describe ".call" do
    it "returns blocks as ContentBlock representations" do
      doc = create(:document)
      create(:edition, :published, document: doc)

      result = described_class.call
      expect(result.blocks).to all(be_a(ContentBlock))
    end

    it "excludes draft content blocks" do
      doc_a = create(:document)
      create(:edition, :published, document: doc_a, title: "Doc A published edition", created_at: 1.day.ago)
      create(:edition, :draft, document: doc_a, title: "Doc A draft edition")

      doc_b = create(:document)
      create(:edition, :published, document: doc_b, title: "Doc B published edition")

      excluded_document = create(:document)
      create(:edition, :draft, document: excluded_document)

      result = described_class.call
      expect(result.blocks.map(&:title)).to contain_exactly("Doc A published edition", "Doc B published edition")
    end

    it "filters by block type" do
      pension_doc = create(:document, block_type: "pension")
      create(:edition, :published, document: pension_doc, title: "Pension")

      contact_doc = create(:document, block_type: "contact")
      create(:edition, :published, document: contact_doc, title: "Contact")

      result = described_class.call(block_type: "pension")

      expect(result.blocks.size).to eq(1)
      expect(result.blocks.first.title).to eq("Pension")
    end

    it "filters by organisation" do
      organisations = [
        build(:organisation, id: SecureRandom.uuid, name: "Org 1"),
        build(:organisation, id: SecureRandom.uuid, name: "Org 2"),
      ]

      allow(Organisation).to receive(:all).and_return(organisations)

      org_1_edition = create(:edition, :published, document: create(:document), lead_organisation_id: organisations[0].id)
      _org_2_edition = create(:edition, :published, document: create(:document), lead_organisation_id: organisations[1].id)

      result = described_class.call(lead_organisation_id: org_1_edition.lead_organisation_id)

      expect(result.blocks.size).to eq(1)
      expect(result.blocks.first.lead_organisation.id).to eq(org_1_edition.lead_organisation_id)
    end

    it "filters by keyword" do
      document_with_first_keyword = create(:document)
      _edition_with_first_keyword = create(:edition,
                                           :published,
                                           document: document_with_first_keyword,
                                           title: "first")
      document_without_first_keyword = create(:document)
      _edition_without_first_keyword = create(:edition, :published, document: document_without_first_keyword,
                                                                    title: "second")

      allow(Document).to receive(:with_keyword)
        .with("keyword")
        .and_return(Document.where(id: document_with_first_keyword.id))

      result = described_class.call(keyword: "keyword")

      expect(result.blocks.size).to eq(1)
      expect(result.blocks.first.title).to eq("first")
    end

    context "with multiple blocks" do
      before do
        15.times do |i|
          document = create(:document)
          create(:edition, :published, document:, title: "Doc #{i + 1}", created_at: i.days.ago)
        end
      end

      it "returns all blocks" do
        result = described_class.call
        expect(result.blocks.size).to eq(15)
      end

      it "returns all blocks ordered by newest edition creation date first" do
        result = described_class.call

        expect(result.blocks.first.title).to eq("Doc 1")
        expect(result.blocks.last.title).to eq("Doc 15")
      end
    end
  end
end
