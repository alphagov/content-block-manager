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

      expect(result.current_page).to eq(1)
      expect(result.total_pages).to eq(1)
      expect(result.total_count).to eq(2)

      expect(result.blocks).to all(be_a(ContentBlock))

      expect(result.blocks.size).to eq(2)
      #  Robust: Cares about the content, not the order
      expect(result.blocks.map(&:title)).to match_array(["Doc A new edition", "Doc B new edition"])
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

    it "returns paginated results ordered by newest edition first" do
      15.times do |i|
        document = create(:document)
        create(:edition, :published, document:, title: "Doc #{i + 1}", created_at: i.days.ago)
      end

      page_1_result = described_class.call(page: 1)

      expect(page_1_result.current_page).to eq(1)
      expect(page_1_result.total_pages).to eq(2)
      expect(page_1_result.total_count).to eq(15)

      expect(page_1_result.blocks.size).to eq(10)
      expect(page_1_result.blocks.first.title).to eq("Doc 1")
      expect(page_1_result.blocks.last.title).to eq("Doc 10")

      page_2_result = described_class.call(page: 2)

      expect(page_2_result.current_page).to eq(2)
      expect(page_2_result.total_pages).to eq(2)
      expect(page_2_result.total_count).to eq(15)

      expect(page_2_result.blocks.size).to eq(5)
      expect(page_2_result.blocks.first.title).to eq("Doc 11")
      expect(page_2_result.blocks.last.title).to eq("Doc 15")
    end
  end
end
