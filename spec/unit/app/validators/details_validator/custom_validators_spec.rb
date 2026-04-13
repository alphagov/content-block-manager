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

  describe "validating with a minimum datetime" do
    let(:body) do
      {
        "type" => "object",
        "additionalProperties" => false,
        "properties" => {
          "date_range" => {
            "type" => "object",
            "additionalProperties" => false,
            "properties" => {
              "start" => {
                "type" => "string",
                "format" => "date-time",
              },
              "end" => {
                "type" => "string",
                "format" => "date-time",
                "formatMinimum" => { "$ref" => "#/date_range/start" },
              },
            },
          },
        },
      }
    end

    let(:schema) { build(:schema, body:) }

    before do
      allow_any_instance_of(Edition).to receive(:schema).and_return(schema)
    end

    it "is invalid if the end datetime is before the start datetime" do
      edition = build(
        :edition,
        :pension,
        details: {
          date_range: {
            start: "2026-04-06T09:00:00+01:00",
            end: "2026-04-06T08:00:00+01:00",
          },
        },
      )

      expect(edition).to be_invalid
      expect(edition).to have_error_for(:details_date_range_end)
                           .with_error_message_for(
                             type: "minimum",
                             attribute: "End",
                             minimum_date: "date range start",
                           )
    end

    it "is invalid if the end datetime equals the start datetime" do
      edition = build(
        :edition,
        :pension,
        details: {
          date_range: {
            start: "2026-04-06T09:00:00+01:00",
            end: "2026-04-06T09:00:00+01:00",
          },
        },
      )

      expect(edition).to be_invalid
      expect(edition).to have_error_for(:details_date_range_end)
    end

    it "is valid if the end datetime is after the start datetime" do
      edition = build(
        :edition,
        :pension,
        details: {
          date_range: {
            start: "2026-04-06T09:00:00+01:00",
            end: "2026-04-06T10:00:00+01:00",
          },
        },
      )

      expect(edition).to be_valid
    end

    it "correctly compares datetimes across timezone boundaries" do
      edition = build(
        :edition,
        :pension,
        details: {
          date_range: {
            # These are the same instant in time (09:00 UTC = 10:00 BST)
            start: "2026-04-06T10:00:00+01:00",
            end: "2026-04-06T09:00:00+00:00",
          },
        },
      )

      expect(edition).to be_invalid
      expect(edition).to have_error_for(:details_date_range_end)
    end
  end

  describe "validating with an unsupported format" do
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

    it "raises an error when formatMinimum is used on a non-datetime field" do
      edition = build(
        :edition,
        :pension,
        details: {
          date: "2000-01-01",
        },
      )

      expect { edition.valid? }.to raise_error(
        ArgumentError,
        'formatMinimum is only supported for date-time fields, got format: "date"',
      )
    end
  end
end
