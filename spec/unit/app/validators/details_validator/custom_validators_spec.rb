RSpec.describe DetailsValidator::CustomValidators do
  describe "#format_date_minimum guard clauses" do
    let(:validator_class) do
      Class.new do
        include DetailsValidator::CustomValidators
      end
    end

    let(:validator) { validator_class.new }

    describe "when the instance is not a string" do
      it "does not raise LocalJumpError" do
        validation_proc = validator.format_date_minimum({})
        schema = { "format" => "date-time", "formatMinimum" => "2026-01-01T00:00:00Z" }

        # nil value - would occur if a datetime field is optional and not provided
        expect { validation_proc.call(nil, schema, "/some/path") }
          .not_to raise_error

        # integer value - defensive check against unexpected input
        expect { validation_proc.call(123, schema, "/some/path") }
          .not_to raise_error
      end
    end

    describe "when formatMinimum is nil in the schema" do
      it "does not raise LocalJumpError" do
        validation_proc = validator.format_date_minimum({})
        schema = { "format" => "date-time" }

        expect { validation_proc.call("2026-04-06T09:00:00+01:00", schema, "/some/path") }
          .not_to raise_error
      end
    end
  end

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

    let(:schema) { build(:schema, body:) }

    before do
      allow_any_instance_of(Edition).to receive(:schema).and_return(schema)
    end

    it "validates the minimum value of a date field" do
      edition = build(
        :edition,
        :pension,
        details: {
          date: "2000-01-01",
        },
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
        )

        expect(edition).to be_invalid

        expect(edition).to have_error_for(:details_end_date)
                             .with_error_message_for(
                               type: "minimum",
                               attribute: "End date",
                               minimum_date: "start date",
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
        )

        translated_date = "Translated date"

        allow(I18n).to receive(:t).and_call_original

        expect(I18n).to receive(:t).with(
          "start_date",
          scope: [:edition, :labels, schema.block_type],
          default: "start date",
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
        )

        expect(edition).to be_valid
      end
    end
  end
end
