RSpec.describe Edition::ValidatesUniquenessOfTitle do
  describe "validations" do
    let(:document) { build(:document) }
    let(:edition) { build(:edition, title: "A unique title", document:) }

    it "is valid with a unique title" do
      expect(edition).to be_valid
    end

    context "when a different document has an edition with the same title" do
      before do
        create(:edition, title: "A unique title", document: create(:document))
      end

      it "is invalid with a non-unique title" do
        expect(edition).not_to be_valid
        expect(edition.errors[:title]).to include(I18n.t("activerecord.errors.models.edition.title.not_unique"))
      end

      it "is valid when the uniqueness check is ignored" do
        edition.accept_risk_of_duplicate_title = true

        expect(edition).to be_valid
      end

      it "is valid when the block has a published edition" do
        previous_edition = create(:edition, document:, state: "published")
        edition.document.editions << previous_edition

        expect(edition).to be_valid
      end
    end

    context "when the same document has an edition with the same title" do
      before do
        create(:edition, title: "A unique title", document:)
      end

      it "is valid because editions of the same document can share titles" do
        expect(edition).to be_valid
      end
    end
  end
end
