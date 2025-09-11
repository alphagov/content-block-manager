require "test_helper"

class HasLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#lead_organisation" do
    let(:organisation) { build(:organisation) }
    let(:edition) do
      create(
        :edition,
        lead_organisation_id: organisation.id,
        document: create(:document, :pension),
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
