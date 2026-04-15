RSpec.describe DateAndTime::RawValues do
  describe "::new" do
    it "creates an instance with all required attributes" do
      raw_datetime = described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: 9,
        min: 30,
      )

      expect(raw_datetime.year).to eq("2025")
      expect(raw_datetime.month).to eq("04")
      expect(raw_datetime.day).to eq("06")
      expect(raw_datetime.hour).to eq(9)
      expect(raw_datetime.min).to eq(30)
    end

    it "accepts string values for year, month, day (preserving raw input)" do
      raw_datetime = described_class.new(
        year: "abc",
        month: "30",
        day: "invalid",
        hour: 0,
        min: 0,
      )

      expect(raw_datetime.year).to eq("abc")
      expect(raw_datetime.month).to eq("30")
      expect(raw_datetime.day).to eq("invalid")
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

      raw_datetime = described_class.from_params(params, "start")

      expect(raw_datetime.year).to eq("2025")
      expect(raw_datetime.month).to eq("04")
      expect(raw_datetime.day).to eq("06")
      expect(raw_datetime.hour).to eq(9)
      expect(raw_datetime.min).to eq(30)
    end

    it "preserves raw string values for year, month, day" do
      params = {
        "start(1i)" => "abc",
        "start(2i)" => "30",
        "start(3i)" => "invalid",
        "start(4i)" => "09",
        "start(5i)" => "30",
      }

      raw_datetime = described_class.from_params(params, "start")

      expect(raw_datetime.year).to eq("abc")
      expect(raw_datetime.month).to eq("30")
      expect(raw_datetime.day).to eq("invalid")
    end

    it "converts hour and minute to integers" do
      params = {
        "start(1i)" => "2025",
        "start(2i)" => "04",
        "start(3i)" => "06",
        "start(4i)" => "09",
        "start(5i)" => "30",
      }

      raw_datetime = described_class.from_params(params, "start")

      expect(raw_datetime.hour).to eq(9)
      expect(raw_datetime.min).to eq(30)
      expect(raw_datetime.hour).to be_a(Integer)
      expect(raw_datetime.min).to be_a(Integer)
    end

    it "returns nil for blank date fields" do
      params = {
        "start(1i)" => "",
        "start(2i)" => "",
        "start(3i)" => "",
        "start(4i)" => "09",
        "start(5i)" => "30",
      }

      raw_datetime = described_class.from_params(params, "start")

      expect(raw_datetime.year).to be_nil
      expect(raw_datetime.month).to be_nil
      expect(raw_datetime.day).to be_nil
    end

    it "returns nil for blank time fields" do
      params = {
        "start(1i)" => "2025",
        "start(2i)" => "04",
        "start(3i)" => "06",
        "start(4i)" => "",
        "start(5i)" => "",
      }

      raw_datetime = described_class.from_params(params, "start")

      expect(raw_datetime.hour).to be_nil
      expect(raw_datetime.min).to be_nil
    end

    it "works with different field names" do
      params = {
        "end_date(1i)" => "2026",
        "end_date(2i)" => "12",
        "end_date(3i)" => "31",
        "end_date(4i)" => "23",
        "end_date(5i)" => "59",
      }

      raw_datetime = described_class.from_params(params, "end_date")

      expect(raw_datetime.year).to eq("2026")
      expect(raw_datetime.month).to eq("12")
      expect(raw_datetime.day).to eq("31")
      expect(raw_datetime.hour).to eq(23)
      expect(raw_datetime.min).to eq(59)
    end
  end

  describe "interface compatibility with Time (view is given Time when loading from #details)" do
    it "responds to year, month, day, hour, min like Time objects" do
      raw_datetime = described_class.new(
        year: "2025",
        month: "04",
        day: "06",
        hour: 9,
        min: 30,
      )
      time = Time.zone.local(2025, 4, 6, 9, 30)
      aggregate_failures do
        expect(raw_datetime).to respond_to(:year)
        expect(raw_datetime).to respond_to(:month)
        expect(raw_datetime).to respond_to(:day)
        expect(raw_datetime).to respond_to(:hour)
        expect(raw_datetime).to respond_to(:min)

        expect(time).to respond_to(:year)
        expect(time).to respond_to(:month)
        expect(time).to respond_to(:day)
        expect(time).to respond_to(:hour)
        expect(time).to respond_to(:min)
      end
    end
  end
end
