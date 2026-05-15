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

    it "filters by block type" do
      pension_doc = create(:document, block_type: "pension")
      create(:edition, :published, document: pension_doc, title: "Pension")

      contact_doc = create(:document, block_type: "contact")
      create(:edition, :published, document: contact_doc, title: "Contact")

      result = described_class.call(block_type: "pension")

      expect(result.size).to eq(1)
      expect(result.first.title).to eq("Pension")
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

      expect(result.size).to eq(1)
      expect(result.first.lead_organisation.id).to eq(org_1_edition.lead_organisation_id)
    end
  end
end
