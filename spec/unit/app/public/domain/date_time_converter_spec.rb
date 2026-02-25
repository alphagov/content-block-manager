RSpec.describe DateTimeConverter do
  describe "when converting from a date time object with rails array-style fields" do
    let(:date_time_obj) do
      { "foo(5i)" => "33",
        "foo(2i)" => "1",
        "foo(3i)" => "2",
        "foo(4i)" => "22",
        "foo(1i)" => "2001" }
    end
    let(:converter) { DateTimeConverter.from_object(date_object: date_time_obj, field_name: "foo") }
    let(:date_time) { converter.date_time }

    it "should return a Time with the correctly set fields" do
      expect(date_time).to be_a(Time)

      expect(date_time.year).to eq(2001)
      expect(date_time.month).to eq(1)
      expect(date_time.day).to eq(2)
      expect(date_time.hour).to eq(22)
      expect(date_time.min).to eq(33)
    end

    describe "when converting to a date string" do
      let(:date) { converter.to_date_string }

      it "should be in a dash-separated format, year first" do
        expect(date).to eq("2001-01-02")
      end
    end

    describe "when converting to a time string" do
      let(:time) { converter.to_time_string }

      it "should be in a colon-separated format" do
        expect(time).to eq("22:33")
      end
    end
  end

  describe "when converting from date and time as strings" do
    let(:date_string) { "3000-12-25" }
    let(:time_string) { "01:23" }
    let(:converter) { DateTimeConverter.from_strings(date: date_string, time: time_string) }
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
