RSpec.describe Edition::DateTimeParts do
  subject(:date_time_parts) do
    described_class.new(
      edition:,
      params:,
      block_type:,
      field_name:,
      date_field:,
      time_field:,
    )
  end

  let(:block_type) { "date_range" }
  let(:field_name) { "start" }
  let(:date_field) { double(name: "date") }
  let(:time_field) { double(name: "time") }
  let(:params) { ActionController::Parameters.new({}) }

  describe "date and time part readers" do
    context "when details contain a valid iso8601 date and time" do
      let(:edition) do
        build(:edition, details: {
          "date_range" => {
            "start" => {
              "date" => "2001-02-03",
              "time" => "04:05",
            },
          },
        })
      end

      it "returns parts from parsed_time" do
        aggregate_failures do
          expect(date_time_parts.year).to eq(2001)
          expect(date_time_parts.month).to eq(2)
          expect(date_time_parts.day).to eq(3)
          expect(date_time_parts.hour).to eq(4)
          expect(date_time_parts.min).to eq(5)
        end
      end
    end

    context "when both details and params are present" do
      let(:edition) do
        build(:edition, details: {
          "date_range" => {
            "start" => {
              "date" => "2001-02-03",
              "time" => "04:05",
            },
          },
        })
      end

      let(:params) do
        ActionController::Parameters.new({
          edition: {
            details: {
              "date_range" => {
                "start" => {
                  "date(1i)" => "2024",
                  "date(2i)" => "10",
                  "date(3i)" => "15",
                  "time(4i)" => "11",
                  "time(5i)" => "45",
                },
              },
            },
          },
        })
      end

      it "prefers param values" do
        aggregate_failures do
          expect(date_time_parts.year).to eq("2024")
          expect(date_time_parts.month).to eq("10")
          expect(date_time_parts.day).to eq("15")
          expect(date_time_parts.hour).to eq("11")
          expect(date_time_parts.min).to eq("45")
        end
      end
    end

    context "when details contain invalid date/time values" do
      let(:edition) do
        build(:edition, details: {
          "date_range" => {
            "start" => {
              "date" => "1111111-34444-99999",
              "time" => "222222:4444",
            },
          },
        })
      end

      let(:params) do
        ActionController::Parameters.new({
          edition: {
            details: {
              "date_range" => {
                "start" => {
                  "date(1i)" => "1111111",
                  "date(2i)" => "34444",
                  "date(3i)" => "99999",
                  "time(4i)" => "222222",
                  "time(5i)" => "4444",
                },
              },
            },
          },
        })
      end

      it "uses param values" do
        aggregate_failures do
          expect(date_time_parts.year).to eq("1111111")
          expect(date_time_parts.month).to eq("34444")
          expect(date_time_parts.day).to eq("99999")
          expect(date_time_parts.hour).to eq("222222")
          expect(date_time_parts.min).to eq("4444")
        end
      end

      it "returns nil for parsed_time" do
        expect(date_time_parts.parsed_time).to be_nil
      end
    end

    context "when there are no matching details or params" do
      let(:edition) { build(:edition, details: {}) }

      it "returns nil for all parts" do
        aggregate_failures do
          expect(date_time_parts.year).to be_nil
          expect(date_time_parts.month).to be_nil
          expect(date_time_parts.day).to be_nil
          expect(date_time_parts.hour).to be_nil
          expect(date_time_parts.min).to be_nil
        end
      end
    end
  end

  describe "Edition::ParsedDateTime compatibility" do
    let(:edition) { build(:edition, details: {}) }

    it "inherits from DateTimeParts" do
      expect(Edition::ParsedDateTime).to be < Edition::DateTimeParts
    end
  end
end
