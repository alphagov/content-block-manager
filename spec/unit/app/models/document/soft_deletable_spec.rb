RSpec.describe Document::SoftDeletable do
  let(:document) { create(:document, :pension) }

  describe "#soft_delete" do
    it "sets the deleted_at column" do
      document.soft_delete

      document.reload

      expect(Time.zone.now).to eq(document.deleted_at)
    end
  end

  describe "#soft_deleted?" do
    it "returns true when a record has been soft deleted" do
      document.soft_delete

      expect(document.soft_deleted?).to be(true)
    end

    it "returns false when a record has not been soft deleted" do
      expect(document.soft_deleted?).to be(false)
    end
  end

  it "ensures soft-deleted records do not appear in the default scope" do
    document.soft_delete

    expect(Document.all).to eq([])

    expect { Document.find(document.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
