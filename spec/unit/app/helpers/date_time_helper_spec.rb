RSpec.describe DateTimeHelper, type: :helper do
  let(:name_prefix) { "edition[details][date_range]" }
  let(:field_name_value) { "start" }

  let(:date_field_value) { build(:field, name: "date", format: "date") }
  let(:time_field_value) { build(:field, name: "time", format: "time") }
  let(:nested_fields) { [date_field_value, time_field_value] }

  describe "#date_time_field_name" do
    {
      year: "edition[details][date_range][start][date(1i)]",
      month: "edition[details][date_range][start][date(2i)]",
      day: "edition[details][date_range][start][date(3i)]",
      hour: "edition[details][date_range][start][time(4i)]",
      minute: "edition[details][date_range][start][time(5i)]",
    }.each do |part, expected_field_name|
      it "builds the #{part} field name" do
        expect(date_time_field_name(name_prefix:, field_name: field_name_value, nested_fields:, part:)).to eq(expected_field_name)
      end
    end

    it "accepts symbol parts" do
      expect(date_time_field_name(name_prefix:, field_name: field_name_value, nested_fields:, part: :year)).to eq("edition[details][date_range][start][date(1i)]")
    end

    it "raises for unknown parts" do
      expect {
        date_time_field_name(name_prefix:, field_name: field_name_value, nested_fields:, part: "second")
      }.to raise_error(ArgumentError, "Unknown date/time part: second")
    end
  end

  describe "#is_date?" do
    it "returns true for date parts" do
      expect(is_date?("year")).to be(true)
      expect(is_date?("month")).to be(true)
      expect(is_date?("day")).to be(true)
    end

    it "returns false for non-date parts" do
      expect(is_date?("hour")).to be(false)
      expect(is_date?("minute")).to be(false)
      expect(is_date?("second")).to be(false)
    end
  end

  describe "#get_date_field" do
    it "returns the nested date field" do
      expect(get_date_field(nested_fields)).to eq(date_field_value)
    end

    it "raises if no nested date field exists" do
      expect { get_date_field([time_field_value]) }.to raise_error(ArgumentError, "No nested date field found")
    end
  end

  describe "#get_time_field" do
    it "returns the nested time field" do
      expect(get_time_field(nested_fields)).to eq(time_field_value)
    end

    it "raises if no nested time field exists" do
      expect { get_time_field([date_field_value]) }.to raise_error(ArgumentError, "No nested time field found")
    end
  end
end
