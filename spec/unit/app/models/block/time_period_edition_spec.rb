RSpec.describe Block::TimePeriodEdition, type: :model do
  describe "inheritance" do
    it "inherits from Block::Edition" do
      expect(described_class.superclass).to eq(Block::Edition)
    end

    it "uses STI with correct type value" do
      document = Block::Document.create!(sluggable_string: "test-block", block_type: "time_period")
      edition = described_class.create!(
        document: document,
        title: "Test Time Period",
      )

      expect(edition.type).to eq("Block::TimePeriodEdition")
      expect(Block::Edition.find(edition.id)).to be_a(Block::TimePeriodEdition)
    end
  end

  describe "validations" do
    it "inherits title presence validation from Block::Edition" do
      edition = described_class.new(title: nil)
      expect(edition).not_to be_valid
      expect(edition.errors[:title]).to include("can't be blank")
    end
  end
end
