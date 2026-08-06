RSpec.describe V2::TimePeriodEdition, type: :model do
  let(:creator) { create(:user) }

  describe "inheritance" do
    it "inherits from V2::Edition" do
      expect(described_class.superclass).to eq(V2::Edition)
    end

    it "uses STI with correct type value" do
      document = V2::Document.create!(sluggable_string: "test-block", block_type: "time_period")
      edition = described_class.create!(
        document: document,
        title: "Test Time Period",
        lead_organisation_id: SecureRandom.uuid,
        creator:,
      )

      expect(edition.type).to eq("V2::TimePeriodEdition")
      expect(V2::Edition.find(edition.id)).to be_a(V2::TimePeriodEdition)
    end
  end

  describe "validations" do
    it "inherits title presence validation from V2::Edition" do
      edition = described_class.new(title: nil, lead_organisation_id: SecureRandom.uuid)
      expect(edition).not_to be_valid
      expect(edition.errors[:title]).to include("cannot be blank")
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:date_range).class_name("V2::TimePeriodDateRange").dependent(:destroy) }
  end

  describe "nested attributes" do
    it "accepts nested attributes for date_range" do
      edition = create(:v2_time_period_edition)

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

  describe "#to_details" do
    it "returns hash with description and date_range to_details" do
      date_range = build(:v2_time_period_date_range,
                         start: Time.zone.parse("2025-04-06 00:00"),
                         end: Time.zone.parse("2026-04-05 23:59"))
      edition = build(:v2_time_period_edition,
                      description: "Tax year 2025/26",
                      date_range: date_range)

      expect(edition.to_details).to eq({
        "description" => "Tax year 2025/26",
        "date_range" => {
          "start" => "2025-04-06 00:00:00.000000000 +0100",
          "end" => "2026-04-05 23:59:00.000000000 +0100",
        },
      })
    end

    it "returns hash with only description when date_range is nil" do
      edition = build(:v2_time_period_edition, description: "Tax year 2025/26")

      expect(edition.to_details).to eq({
        "description" => "Tax year 2025/26",
      })
    end

    it "returns hash with only date_range when description is nil" do
      date_range = build(:v2_time_period_date_range,
                         start: Time.zone.parse("2025-04-06 00:00"),
                         end: Time.zone.parse("2026-04-05 23:59"))
      edition = build(:v2_time_period_edition,
                      description: nil,
                      date_range: date_range)

      expect(edition.to_details).to eq({
        "date_range" => {
          "start" => "2025-04-06 00:00:00.000000000 +0100",
          "end" => "2026-04-05 23:59:00.000000000 +0100",
        },
      })
    end
  end
end
