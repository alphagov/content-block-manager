RSpec.describe Block::TimePeriodDateRange, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:edition).class_name("Block::TimePeriodEdition") }
  end

  describe "validations" do
    let(:edition) { create(:time_period_edition) }

    subject { described_class.new(edition: edition, start: Time.zone.parse("2025-04-06 00:00"), end: Time.zone.parse("2026-04-05 23:59")) }

    it { is_expected.to validate_presence_of(:start) }
    it { is_expected.to validate_presence_of(:end) }

    describe "end_date_after_start_date" do
      it "is invalid when end is before start" do
        date_range = described_class.new(
          edition: edition,
          start: Time.zone.parse("2025-04-06 00:00"),
          end: Time.zone.parse("2025-04-05 23:59"),
        )
        expect(date_range).not_to be_valid
        expect(date_range.errors[:end]).to include("must be after start date")
      end

      it "is invalid when end equals start" do
        same_time = Time.zone.parse("2025-04-06 00:00")
        date_range = described_class.new(
          edition: edition,
          start: same_time,
          end: same_time,
        )
        expect(date_range).not_to be_valid
        expect(date_range.errors[:end]).to include("must be after start date")
      end

      it "is valid when end is after start" do
        date_range = described_class.new(
          edition: edition,
          start: Time.zone.parse("2025-04-06 00:00"),
          end: Time.zone.parse("2026-04-05 23:59"),
        )
        expect(date_range).to be_valid
      end
    end
  end

  describe "#to_details" do
    it "returns hash with formatted start and end date/time" do
      date_range = described_class.new(
        start: Time.zone.parse("2025-04-06 00:00"),
        end: Time.zone.parse("2026-04-05 23:59"),
      )

      expect(date_range.to_details).to eq({
        "start" => {
          "date" => "2025-04-06",
          "time" => "00:00",
        },
        "end" => {
          "date" => "2026-04-05",
          "time" => "23:59",
        },
      })
    end

    it "formats times with leading zeros" do
      date_range = described_class.new(
        start: Time.zone.parse("2025-01-01 09:05"),
        end: Time.zone.parse("2025-12-31 18:30"),
      )

      result = date_range.to_details
      expect(result["start"]["time"]).to eq("09:05")
      expect(result["end"]["time"]).to eq("18:30")
    end
  end
end
