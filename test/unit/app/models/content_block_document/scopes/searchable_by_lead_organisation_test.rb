require "test_helper"

class ContentBlockManager::SearchableByLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_lead_organisation" do
    it "finds documents with lead organisation on latest edition" do
      matching_organisation = build(:organisation)
      document_with_org = create(:content_block_document, :pension)
      _edition_with_org = create(:content_block_edition,
                                 :pension,
                                 document: document_with_org,
                                 lead_organisation_id: matching_organisation.id)
      document_without_org = create(:content_block_document, :pension)
      _edition_without_org = create(:content_block_edition, :pension, document: document_without_org)
      _document_without_latest_edition = create(:content_block_document, :pension)
      assert_equal [document_with_org], ContentBlockManager::ContentBlock::Document.with_lead_organisation(matching_organisation.id)
    end
  end
end
