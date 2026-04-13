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

    let(:start_datetime) { "2025-04-06T00:00:00+01:00" }
    let(:end_datetime) { "2026-04-05T23:59:00+01:00" }

    let(:date_range) do
      {
        start: start_datetime,
        end: end_datetime,
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

    describe "when the start datetime is invalid" do
      let(:start_datetime) { "INVALID DATETIME" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start field" do
        expect(errors[:details_date_range_start]).to include("Invalid Start")
      end
    end

    describe "when the end datetime is invalid" do
      let(:end_datetime) { "INVALID DATETIME" }

      it { is_expected.not_to be_valid }

      it "adds an error to the end field" do
        expect(errors[:details_date_range_end]).to include("Invalid End")
      end
    end

    describe "when the end datetime is before the start datetime" do
      let(:end_datetime) { "2023-04-06T00:00:00+01:00" }

      it { is_expected.not_to be_valid }

      it "adds an error to the end field" do
        expect(errors[:details_date_range_end]).to include("End must be after date range start")
      end
    end

    describe "when the end datetime equals the start datetime" do
      let(:end_datetime) { start_datetime }

      it { is_expected.not_to be_valid }

      it "adds an error to the end field" do
        expect(errors[:details_date_range_end]).to include("End must be after date range start")
      end
    end
  end
end
