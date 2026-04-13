RSpec.describe DateAndTime::Converter do
  describe ".from_params" do
    subject(:converter) { described_class.from_params(params: params, field_name: field_name) }

    let(:field_name) { "start" }

    context "with valid date and time params" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "4",
          "start(3i)" => "6",
          "start(4i)" => "09",
          "start(5i)" => "30",
        }
      end

      it "is valid" do
        expect(converter).to be_valid
      end

      it "has no errors" do
        expect(converter.errors).to be_empty
      end

      it "parses the datetime correctly" do
        expect(converter.date_time.year).to eq(2026)
        expect(converter.date_time.month).to eq(4)
        expect(converter.date_time.day).to eq(6)
        expect(converter.date_time.hour).to eq(9)
        expect(converter.date_time.min).to eq(30)
      end

      it "returns ISO 8601 format with timezone" do
        expect(converter.to_iso8601).to match(/\A2026-04-06T09:30:00[+-]\d{2}:\d{2}\z/)
      end

      it "preserves raw params" do
        expect(converter.raw_params).to eq(params)
      end
    end

    context "with blank time fields" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "4",
          "start(3i)" => "6",
          "start(4i)" => "",
          "start(5i)" => "",
        }
      end

      it "is valid" do
        expect(converter).to be_valid
      end

      it "defaults time to 00:00" do
        expect(converter.date_time.hour).to eq(0)
        expect(converter.date_time.min).to eq(0)
      end
    end

    context "with missing date fields" do
      let(:params) do
        {
          "start(1i)" => "",
          "start(2i)" => "",
          "start(3i)" => "",
          "start(4i)" => "09",
          "start(5i)" => "30",
        }
      end

      it "is not valid" do
        expect(converter).not_to be_valid
      end

      it "has a presence error" do
        expect(converter.errors).to include(:date_blank)
      end

      it "returns nil for date_time" do
        expect(converter.date_time).to be_nil
      end

      it "returns nil for to_iso8601" do
        expect(converter.to_iso8601).to be_nil
      end
    end

    context "with invalid date (e.g., February 30)" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "2",
          "start(3i)" => "30",
          "start(4i)" => "09",
          "start(5i)" => "30",
        }
      end

      it "is not valid" do
        expect(converter).not_to be_valid
      end

      it "has an invalid date error" do
        expect(converter.errors).to include(:date_invalid)
      end

      it "preserves raw params for form repopulation" do
        expect(converter.raw_params["start(3i)"]).to eq("30")
      end
    end

    context "with non-numeric date values" do
      let(:params) do
        {
          "start(1i)" => "abc",
          "start(2i)" => "4",
          "start(3i)" => "6",
          "start(4i)" => "09",
          "start(5i)" => "30",
        }
      end

      it "is not valid" do
        expect(converter).not_to be_valid
      end

      it "has an invalid date error" do
        expect(converter.errors).to include(:date_invalid)
      end
    end

    context "with partial date fields (only year)" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "",
          "start(3i)" => "",
          "start(4i)" => "",
          "start(5i)" => "",
        }
      end

      it "is not valid" do
        expect(converter).not_to be_valid
      end

      it "has an invalid date error" do
        expect(converter.errors).to include(:date_invalid)
      end
    end

    context "with negative month value" do
      let(:params) do
        {
          "start(1i)" => "2026",
          "start(2i)" => "-1",
          "start(3i)" => "6",
          "start(4i)" => "09",
          "start(5i)" => "30",
        }
      end

      it "is not valid" do
        expect(converter).not_to be_valid
      end

      it "has an invalid date error" do
        expect(converter.errors).to include(:date_invalid)
      end
    end
  end

  describe "when converting from date and time as strings" do
    let(:date_string) { "3000-12-25" }
    let(:time_string) { "01:23" }
    let(:converter) { DateAndTime::Converter.from_strings(date: date_string, time: time_string) }
    let(:date_time) { converter.date_time }

    it "should return a Time with the correctly set fields" do
      expect(date_time).to be_a(Time)

      expect(date_time.year).to eq(3000)
      expect(date_time.month).to eq(12)
      expect(date_time.day).to eq(25)
      expect(date_time.hour).to eq(1)
      expect(date_time.min).to eq(23)
    end
  end
end
