RSpec.describe DetailsValidator::SchemaValidationRunner do
  let(:schema_body) do
    {
      "type" => "object",
      "required" => %w[foo bar],
      "additionalProperties" => false,
      "properties" => {
        "foo" => { "type" => "string", "format" => "email" },
        "bar" => { "type" => "string", "format" => "date" },
      },
    }
  end

  let(:details) do
    {
      foo: "",
      bar: "2024-01-01",
    }
  end

  subject(:runner) do
    described_class.new(
      schema_body:,
      details:,
    )
  end

  it "returns schema errors for required values" do
    errors = runner.call

    expect(errors).to include(include("type" => "required", "data_pointer" => ""))
  end

  describe "custom formats" do
    describe "time" do
      let(:schema_body) do
        {
          "type" => "object",
          "required" => %w[start_time],
          "additionalProperties" => false,
          "properties" => {
            "start_time" => { "type" => "string", "format" => "time" },
          },
        }
      end

      context "with invalid values" do
        let(:details) do
          {
            start_time: "26:99",
          }
        end

        it "returns format errors" do
          errors = runner.call

          expect(errors).to include(include("type" => "format", "data_pointer" => "/start_time"))
        end
      end

      context "with valid values" do
        let(:details) do
          {
            start_time: "12:45",
          }
        end

        it "returns no errors" do
          expect(runner.call.to_a).to be_empty
        end
      end
    end
  end

  describe "keywords" do
    describe "validating with a minimum date" do
      let(:schema_body) do
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

      context "when the date is before the minimum date" do
        let(:details) do
          {
            date: "2000-01-01",
          }
        end

        it "returns an error" do
          errors = runner.call

          expect(errors).to include(include("type" => "formatMinimum", "data_pointer" => "/date"))
        end
      end

      context "when the date is after the minimum date" do
        let(:details) do
          {
            date: "2023-01-01",
          }
        end

        it "returns no errors" do
          expect(runner.call.to_a).to be_empty
        end
      end

      context "when formatMinimum is a pointer" do
        let(:schema_body) do
          {
            "type" => "object",
            "additionalProperties" => false,
            "properties" => {
              "start_date" => {
                "type" => "string",
                "format" => "date",
              },
              "end_date" => {
                "type" => "string",
                "format" => "date",
                "formatMinimum" => { "$ref" => "#/start_date" },
              },
            },
          }
        end

        context "when the date is before the pointer" do
          let(:details) do
            {
              start_date: "2022-01-01",
              end_date: "2000-01-01",
            }
          end

          it "returns an error" do
            errors = runner.call

            expect(errors).to include(include("type" => "formatMinimum", "data_pointer" => "/end_date"))
          end
        end

        context "when the date is after the pointer" do
          let(:details) do
            {
              start_date: "2022-01-01",
              end_date: "2023-01-01",
            }
          end

          it "returns no errors" do
            expect(runner.call.to_a).to be_empty
          end
        end
      end
    end
  end
end
