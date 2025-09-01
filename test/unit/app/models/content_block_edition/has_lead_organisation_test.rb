require "test_helper"

class ContentBlockManager::HasLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#lead_organisation" do
    let(:organisation) { build(:organisation) }
    let(:edition) do
      create(
        :content_block_edition,
        lead_organisation_id: organisation.id,
        document: create(:content_block_document, :pension),
      )
    end

    before do
      Organisation.expects(:find).with(organisation.id).returns(organisation)
    end

    it "returns an organisation object" do
      assert_equal edition.lead_organisation, organisation
    end
  end
end
