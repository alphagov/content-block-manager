RSpec.describe Edition::HasLeadOrganisation do
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
      expect(Organisation).to receive(:find).with(organisation.id).and_return(organisation)
    end

    it "returns an organisation object" do
      expect(organisation).to eq(edition.lead_organisation)
    end
  end
end
