RSpec.describe DateTimeConverter do
  let(:date_time_obj) do
    { "foo(5i)" => "33",
      "foo(2i)" => "1",
      "foo(3i)" => "2",
      "foo(4i)" => "22",
      "foo(1i)" => "2001" }
  end
  let(:converter) { DateTimeConverter.from_object(date_time_obj, "foo") }

  describe "when converting from a date time object with rails array-style fields" do
    let(:date_time) { converter.date_time }

    it "should return a Time with the correctly set fields" do
      expect(date_time).to be_a(Time)

      expect(date_time.year).to eq(2001)
      expect(date_time.month).to eq(1)
      expect(date_time.day).to eq(2)
      expect(date_time.hour).to eq(22)
      expect(date_time.min).to eq(33)
    end
  end
end
