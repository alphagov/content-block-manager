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
  end
end
