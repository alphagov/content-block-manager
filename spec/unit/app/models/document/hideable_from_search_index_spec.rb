RSpec.describe Document::HideableFromSearchIndex do
  let(:user) { create(:user) }

  before do
    allow(Current).to receive(:user).and_return(user)
  end

  describe "when a user is an e2e user" do
    before do
      allow(user).to receive(:is_e2e_user?).and_return(true)
    end

    it "sets the testing_artefact column to true" do
      document = create(:document)

      expect(document.reload.testing_artefact).to be(true)
    end
  end

  describe "when a user is not an e2e user" do
    before do
      allow(user).to receive(:is_e2e_user?).and_return(false)
    end

    it "sets the testing_artefact column to false" do
      document = create(:document)

      expect(document.reload.testing_artefact).to be(false)
    end
  end

  describe "when Current.user is nil" do
    # This should not happen in normal circumstances, but it does happen in tests, so let's ensure we handle it.
    before do
      allow(Current).to receive(:user).and_return(nil)
    end

    it "sets the testing_artefact column to false" do
      document = create(:document)

      expect(document.reload.testing_artefact).to be(false)
    end
  end
end
