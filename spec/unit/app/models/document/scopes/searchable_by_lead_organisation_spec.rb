RSpec.describe Document::Scopes::SearchableByLeadOrganisation do
  describe ".with_lead_organisation" do
    it "finds documents with lead organisation on latest edition" do
      matching_organisation = build(:organisation)
      document_with_org = create(:document, :pension)
      _edition_with_org = create(:edition,
                                 :pension,
                                 :published,
                                 document: document_with_org,
                                 lead_organisation_id: matching_organisation.id)
      document_without_org = create(:document, :pension)
      _edition_without_org = create(:edition, :pension, document: document_without_org)
      _document_without_latest_published_edition = create(:document, :pension)

      expect(Document.with_lead_organisation(matching_organisation.id)).to eq([document_with_org])
    end
  end
end
