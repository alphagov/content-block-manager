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

      expect(edition).to have_error_for(:details_date)
                           .with_error_message_for(
                             type: "minimum",
                             attribute: "Date",
                             minimum_date: Date.iso8601("2022-01-01").to_fs(:long),
                           )
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

    it "does not do minimum validation if the date is invalid" do
      edition = build(
        :edition,
        :pension,
        details: {
          date: "INVALID",
        },
        schema:,
      )

      expect(edition).to be_invalid

      expect(edition).to_not have_error_for(:details_date)
                          .with_error_message_for(
                            type: "minimum",
                            attribute: "Date",
                            minimum_date: Date.iso8601("2022-01-01").to_fs(:long),
                          )

      expect(edition).to have_error_for(:details_date)
                               .with_error_message_for(
                                 type: "invalid",
                                 attribute: "Date",
                               )
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

        expect(edition).to have_error_for(:details_end_date)
                             .with_error_message_for(
                               type: "minimum",
                               attribute: "End date",
                               minimum_date: "Start date",
                             )
      end

      it "uses a translation key for the pointer" do
        edition = build(
          :edition,
          :pension,
          details: {
            start_date: "2025-01-01",
            end_date: "2024-01-01",
          },
          schema:,
        )

        translated_date = "Translated date"

        allow(I18n).to receive(:t).and_call_original

        expect(I18n).to receive(:t).with(
          "start_date",
          scope: [:edition, :labels, schema.block_type],
          default: "Start date",
        ).and_return(translated_date)

        expect(edition).to be_invalid

        expect(edition).to have_error_for(:details_end_date)
                             .with_error_message_for(
                               type: "minimum",
                               attribute: "End date",
                               minimum_date: translated_date,
                             )
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
