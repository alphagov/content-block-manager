RSpec.describe DateAndTime::FieldValues do
  describe "::new" do
    it "creates an instance with all required attributes" do
      field_data = described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.year).to eq("2025")
      expect(field_data.month).to eq("04")
      expect(field_data.day).to eq("06")
      expect(field_data.hour).to eq("09")
      expect(field_data.minute).to eq("30")
    end
  end

  describe "::from_params" do
    it "extracts multiparameter date and time values from params" do
      params = {
        "start(1i)" => "2025",
        "start(2i)" => "04",
        "start(3i)" => "06",
        "start(4i)" => "09",
        "start(5i)" => "30",
      }

      field_data = described_class.from_params(params, "start")

      expect(field_data.year).to eq("2025")
      expect(field_data.month).to eq("04")
      expect(field_data.day).to eq("06")
      expect(field_data.hour).to eq("09")
      expect(field_data.minute).to eq("30")
    end

    it "parses date fields as integers, returning nil for unparseable values" do
      params = {
        "start(1i)" => "2025",
        "start(2i)" => "abc",
        "start(3i)" => "06",
        "start(4i)" => "09",
        "start(5i)" => "30",
      }

      field_data = described_class.from_params(params, "start")

      expect(field_data.year_int).to eq(2025)
      expect(field_data.month_int).to be_nil
      expect(field_data.day_int).to eq(6)
    end

    it "defaults hour and minute to 0 when blank" do
      params = {
        "start(1i)" => "2025",
        "start(2i)" => "04",
        "start(3i)" => "06",
        "start(4i)" => "",
        "start(5i)" => "",
      }

      field_data = described_class.from_params(params, "start")

      expect(field_data.hour_int).to eq(0)
      expect(field_data.minute_int).to eq(0)
    end
  end

  describe "#parse_integer" do
    let(:field_data) do
      described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: "09",
        minute: "30",
      )
    end
    it "returns the integer value for a valid numeric string" do
      expect(field_data.parse_integer("42")).to eq(42)
    end

    it "returns nil for a blank string" do
      expect(field_data.parse_integer("")).to be_nil
    end

    it "returns nil for nil" do
      expect(field_data.parse_integer(nil)).to be_nil
    end

    it "returns nil for a non-numeric string" do
      expect(field_data.parse_integer("abc")).to be_nil
    end

    it "parses strings with leading zeros" do
      expect(field_data.parse_integer("04")).to eq(4)
    end
  end

  describe "#all_date_fields_blank?" do
    it "returns true when year, month, and day are all blank" do
      field_data = described_class.new(
        year: "",
        month: "",
        day: "",
        hour: "09",
        minute: "30",
      )

      expect(field_data.all_date_fields_blank?).to be true
    end

    it "returns false when any date field is present" do
      field_data = described_class.new(
        year: "2025",
        month: "",
        day: "",
        hour: "",
        minute: "",
      )

      expect(field_data.all_date_fields_blank?).to be false
    end
  end

  describe "#any_date_field_unparseable?" do
    it "returns false when all date fields parse to integers" do
      field_data = described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.any_date_field_unparseable?).to be false
    end

    it "returns true when year is unparseable" do
      field_data = described_class.new(
        year: "abc",
        month: "04",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.any_date_field_unparseable?).to be true
    end

    it "returns true when month is unparseable" do
      field_data = described_class.new(
        year: "2025",
        month: "abc",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.any_date_field_unparseable?).to be true
    end

    it "returns true when day is unparseable" do
      field_data = described_class.new(
        year: "2025",
        month: "04",
        day: "abc",
        hour: "09",
        minute: "30",
      )

      expect(field_data.any_date_field_unparseable?).to be true
    end
  end

  describe "#negative_day_or_month_provided?" do
    it "returns false when month and day are positive" do
      field_data = described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.negative_day_or_month_provided?).to be false
    end

    it "returns true when month is zero" do
      field_data = described_class.new(
        year: "2025",
        month: "0",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.negative_day_or_month_provided?).to be true
    end

    it "returns true when day is zero" do
      field_data = described_class.new(
        year: "2025",
        month: "04",
        day: "0",
        hour: "09",
        minute: "30",
      )

      expect(field_data.negative_day_or_month_provided?).to be true
    end

    it "returns true when month is negative" do
      field_data = described_class.new(
        year: "2025",
        month: "-1",
        day: "06",
        hour: "09",
        minute: "30",
      )

      expect(field_data.negative_day_or_month_provided?).to be true
    end
  end
end
