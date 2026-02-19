RSpec.describe DetailsValidator::CustomValidators do
  let(:schema) { build(:schema, body:) }

  describe "validating with a minimum date" do
    let(:body) do
      {
        "type" => "object",
        "additionalProperties" => false,
        "properties" => {
          "date" => {
            "type" => "string",
            "format" => "date",
            "formatMinimum" => "2022-01-01",
          },
        },
      }
    end

    it "validates the minimum value of a date field" do
      edition = build(
        :edition,
        :pension,
        details: {
          date: "2000-01-01",
        },
        schema:,
      )

      expect(edition).to be_invalid

      expect(edition).to have_error_for(:details_date).with_error_message_for(type: "invalid", attribute: "Date")
    end

    it "is valid if the date is after the minimum date" do
      edition = build(
        :edition,
        :pension,
        details: {
          date: "2023-01-01",
        },
        schema:,
      )

      expect(edition).to be_valid
    end

    describe "when formatMinimum is a pointer" do
      let(:body) do
        {
          "type" => "object",
          "additionalProperties" => false,
          "properties" => {
            "start_date" => {
              "type" => "string",
              "format" => "date",
              "formatMinimum" => "2022-01-01",
            },
            "end_date" => {
              "type" => "string",
              "format" => "date",
              "formatMinimum" => { "$ref" => "#/start_date" },
            },
          },
        }
      end

      it "is invalid if the date is before the pointer" do
        edition = build(
          :edition,
          :pension,
          details: {
            start_date: "2025-01-01",
            end_date: "2024-01-01",
          },
          schema:,
        )

        expect(edition).to be_invalid

        expect(edition).to have_error_for(:details_end_date).with_error_message_for(type: "invalid", attribute: "End date")
      end

      it "is valid if the date is after the pointer" do
        edition = build(
          :edition,
          :pension,
          details: {
            start_date: "2025-01-01",
            end_date: "2026-01-01",
          },
          schema:,
        )

        expect(edition).to be_valid
      end
    end
  end
end
