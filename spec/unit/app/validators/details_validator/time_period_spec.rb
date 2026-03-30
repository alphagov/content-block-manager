RSpec.describe DetailsValidator do
  describe "time period schema" do
    let(:document) { build(:document, :time_period) }

    let(:details) do
      {
        description: "Some description",
        note: "Some note",
        date_range:,
      }
    end

    let(:start_date_time) { "2025-04-06T00:00:00Z" }
    let(:end_date_time) { "2026-04-05T23:59:00Z" }

    let(:date_range) do
      {
        start: start_date_time,
        end: end_date_time,
      }
    end

    subject { build(:edition, :time_period, details:, document:) }

    before do
      subject.valid?
    end

    let(:errors) { subject.errors }

    context "when the time period is valid" do
      it { is_expected.to be_valid }
    end

    describe "when the start is invalid" do
      let(:start_date_time) { "INVALID" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start field" do
        expect(errors[:details_date_range_start]).to include("Start date/time is invalid")
      end
    end

    describe "when the end is invalid" do
      let(:end_date_time) { "INVALID" }

      it { is_expected.not_to be_valid }

      it "adds an error to the end field" do
        expect(errors[:details_date_range_end]).to include("End date/time is invalid")
      end
    end

    describe "when the end is before the start" do
      let(:end_date_time) { "2023-04-06T00:00:00Z" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start date field" do
        expect(errors[:details_date_range_end]).to include("End must be after date range start")
      end
    end
  end
end
