RSpec.describe Block::TimePeriodDateRange, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:edition).class_name("Block::TimePeriodEdition") }
  end

  describe "validations" do
    let(:edition) { create(:block_time_period_edition) }

    describe "presence validations" do
      subject { described_class.new(edition: edition, start: Time.zone.parse("2025-01-01 00:00"), end: Time.zone.parse("3333-04-05 12:34")) }

      it { is_expected.to validate_presence_of(:start) }
      it { is_expected.to validate_presence_of(:end) }
    end

    describe "invalid date validation" do
      it "is invalid when start date has invalid month" do
        date_range = described_class.new(edition: edition)
        # Simulate multiparameter assignment with invalid month (23)
        date_range.start = { 1 => 2025, 2 => 23, 3 => 6, 4 => 0, 5 => 0 }
        date_range.end = Time.zone.parse("2026-04-05 23:59")

        expect(date_range).not_to be_valid
        expect(date_range.errors[:start]).to include("Start date is not a valid date")
      end

      it "is invalid when end date has invalid day" do
        date_range = described_class.new(edition: edition)
        date_range.start = Time.zone.parse("2025-04-06 00:00")
        # Simulate multiparameter assignment with invalid day (32)
        date_range.end = { 1 => 2025, 2 => 4, 3 => 32, 4 => 23, 5 => 59 }

        expect(date_range).not_to be_valid
        expect(date_range.errors[:end]).to include("End date is not a valid date")
      end
    end

    describe "#end_date_after_start_date" do
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
    it "returns a hash with formatted start and end datetime" do
      date_range = described_class.new(
        start: Time.zone.parse("2025-04-06 00:00"),
        end: Time.zone.parse("2026-04-05 23:59"),
      )

      expect(date_range.to_details).to eq({
        "start" => "2025-04-06 00:00:00.00000000 +0100 ",
        "end" => "2026-04-05 23:59:00.00000000 +0100",
      })
    end
  end
end
