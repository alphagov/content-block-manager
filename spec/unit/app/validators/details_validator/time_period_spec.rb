RSpec.describe DetailsValidator do
  describe "time period schema" do
    let(:schema_body) { JSON.parse(File.read(Rails.root.join("app/models/schema/definitions/time_period.json"))) }
    let(:schema) { Schema.new("content_block_time_period", schema_body) }

    let(:document) { build(:document, schema:) }

    let(:details) do
      {
        description: "Some description",
        note: "Some note",
        date_range:,
      }
    end

    let(:start_date) { "2025-04-06" }
    let(:start_time) { "00:00" }

    let(:end_date) { "2026-04-05" }
    let(:end_time) { "23:59" }

    let(:date_range) do
      {
        start: {
          date: start_date,
          time: start_time,
        },
        end: {
          date: end_date,
          time: end_time,
        },
      }
    end

    subject { build(:edition, schema: schema, details:, document:) }

    before do
      subject.valid?
    end

    let(:errors) { subject.errors }

    context "when the time period is valid" do
      it { is_expected.to be_valid }
    end

    describe "when the start date is invalid" do
      let(:start_date) { "INVALID DATE" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start date field" do
        expect(errors[:details_date_range_start_date]).to include("Invalid Date")
      end
    end

    describe "when the start time is invalid" do
      let(:start_time) { "INVALID TIME" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start date field" do
        expect(errors[:details_date_range_start_time]).to include("Invalid Time")
      end
    end

    describe "when the end date is invalid" do
      let(:end_date) { "INVALID DATE" }

      it { is_expected.not_to be_valid }

      it "adds an error to the end date field" do
        expect(errors[:details_date_range_end_date]).to include("Invalid Date")
      end
    end

    describe "when the end time is invalid" do
      let(:end_time) { "INVALID TIME" }

      it { is_expected.not_to be_valid }

      it "adds an error to the start date field" do
        expect(errors[:details_date_range_end_time]).to include("Invalid Time")
      end
    end
  end
end
