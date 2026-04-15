RSpec.describe Block::TimePeriodEdition, type: :model do
  describe "inheritance" do
    it "inherits from Block::Edition" do
      expect(described_class.superclass).to eq(Block::Edition)
    end

    it "uses STI with correct type value" do
      document = Block::Document.create!(
        sluggable_string: "test-block",
        block_type: "time_period",
      )
      edition = described_class.create!(
        document: document,
        title: "Test Time Period",
        lead_organisation_id: SecureRandom.uuid,
      )

      expect(edition.type).to eq("Block::TimePeriodEdition")
      expect(Block::Edition.find(edition.id)).to be_a(Block::TimePeriodEdition)
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:date_range).class_name("Block::TimePeriodDateRange").dependent(:destroy) }
  end

  describe "validations" do
    it "inherits title presence validation from Block::Edition" do
      edition = described_class.new(title: nil)
      expect(edition).not_to be_valid
      expect(edition.errors[:title]).to include("cannot be blank")
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for date_range" do
      edition = create(:time_period_edition)

      edition.update!(
        date_range_attributes: {
          start: Time.zone.parse("2025-04-06 00:00"),
          end: Time.zone.parse("2026-04-05 23:59"),
        },
      )

      expect(edition.date_range).to be_present
      expect(edition.date_range.start).to eq(Time.zone.parse("2025-04-06 00:00"))
      expect(edition.date_range.end).to eq(Time.zone.parse("2026-04-05 23:59"))
    end
  end

  describe "#details" do
    it "returns hash with description and date_range details" do
      date_range = build(:block_time_period_date_range,
                         start: Time.zone.parse("2025-04-06 00:00"),
                         end: Time.zone.parse("2026-04-05 23:59"))
      edition = build(:time_period_edition,
                      description: "Tax year 2025/26",
                      date_range: date_range)

      expect(edition.details).to eq({
        "description" => "Tax year 2025/26",
        "date_range" => {
          "start" => {
            "date" => "2025-04-06",
            "time" => "00:00",
          },
          "end" => {
            "date" => "2026-04-05",
            "time" => "23:59",
          },
        },
      })
    end

    it "returns hash with only description when date_range is nil" do
      edition = build(:time_period_edition, description: "Tax year 2025/26")

      expect(edition.details).to eq({
        "description" => "Tax year 2025/26",
      })
    end

    it "returns hash with only date_range when description is nil" do
      date_range = build(:block_time_period_date_range,
                         start: Time.zone.parse("2025-04-06 00:00"),
                         end: Time.zone.parse("2026-04-05 23:59"))
      edition = build(:time_period_edition,
                      description: nil,
                      date_range: date_range)

      expect(edition.details).to eq({
        "date_range" => {
          "start" => {
            "date" => "2025-04-06",
            "time" => "00:00",
          },
          "end" => {
            "date" => "2026-04-05",
            "time" => "23:59",
          },
        },
      })
    end
  end
end
