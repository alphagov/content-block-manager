require "test_helper"

class SearchableByLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_lead_organisation" do
    it "finds documents with lead organisation on latest edition" do
      matching_organisation = build(:organisation)
      document_with_org = create(:document, :pension)
      _edition_with_org = create(:edition,
                                 :pension,
                                 document: document_with_org,
                                 lead_organisation_id: matching_organisation.id)
      document_without_org = create(:document, :pension)
      _edition_without_org = create(:edition, :pension, document: document_without_org)
      _document_without_latest_edition = create(:document, :pension)
      assert_equal [document_with_org], Document.with_lead_organisation(matching_organisation.id)
    end
  end
end
