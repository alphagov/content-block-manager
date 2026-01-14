RSpec.describe ProcessedParams do
  let(:processed_params) { described_class.new(params, schema) }
  let(:schema) { build(:schema, block_type: "block_type") }

  before do
    allow(schema).to receive(:fields).and_return(fields)
  end

  context "when there are no conditionally revealed fields" do
    let(:params) do
      {
        "block_type" => {
          "foo" => "bar",
        },
      }
    end

    let(:fields) do
      [
        double(:field, name: "foo", format: "string", show_field: nil, nested_fields: nil),
      ]
    end

    it "leaves the params unchanged" do
      expect(processed_params.result).to eq(params)
    end
  end

  context "when there are conditionally revealed fields" do
    let(:show_field) { double(:field, name: "show") }
    let(:fields) do
      [
        double(:field, name: "foo", format: "object", show_field:, schema:),
      ]
    end

    let(:params) do
      {
        "block_type" => {
          "foo" => {
            "show" => "true",
            "value" => "bar",
          },
        },
      }
    end

    it "should cast the show field to a boolean" do
      expect(processed_params.result).to eq({
        "block_type" => {
          "foo" => {
            "show" => true,
            "value" => "bar",
          },
        },
      })
    end

    context "if the value of the show field is empty" do
      let(:params) do
        {
          "block_type" => {
            "foo" => {
              "show" => "",
              "value" => "bar",
            },
          },
        }
      end

      it "should remove the object's fields" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "foo" => {},
          },
        })
      end
    end
  end

  context "when there is an object that has a show field nested within an object" do
    let(:show_field) { double(:field, name: "show") }
    let(:nested_fields) do
      [
        double(:nested_field, name: "nested", format: "object", show_field:),
      ]
    end
    let(:fields) do
      [
        double(:field, name: "foo", format: "object", show_field: nil, schema:, nested_fields:),
      ]
    end

    let(:params) do
      {
        "block_type" => {
          "foo" => {
            "nested" => {
              "show" => "true",
              "value" => "bar",
            },
          },
        },
      }
    end

    it "should cast the show field to a boolean" do
      expect(processed_params.result).to eq({
        "block_type" => {
          "foo" => {
            "nested" => {
              "show" => true,
              "value" => "bar",
            },
          },
        },
      })
    end

    context "if the value of the show field is empty" do
      let(:params) do
        {
          "block_type" => {
            "foo" => {
              "nested" => {
                "show" => "",
                "value" => "bar",
              },
            },
          },
        }
      end

      it "should remove the object's fields" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "foo" => {
              "nested" => {},
            },
          },
        })
      end
    end
  end

  context "when there is an object that has a show field within an array" do
    let(:show_field) { double(:field, name: "show") }
    let(:nested_fields) do
      [
        double(:nested_field, name: "nested", format: "object", show_field:),
      ]
    end
    let(:fields) do
      [
        double(:field, name: "foo", format: "array", show_field: nil, schema:, nested_fields:),
      ]
    end

    let(:params) do
      {
        "block_type" => {
          "foo" => [
            {
              "nested" => {
                "show" => "true",
                "value" => "bar",
              },
            },
          ],
        },
      }
    end

    it "should cast the show field to a boolean" do
      expect(processed_params.result).to eq({
        "block_type" => {
          "foo" => [
            {
              "nested" => {
                "show" => true,
                "value" => "bar",
              },
            },
          ],
        },
      })
    end

    context "when the params are not provided" do
      let(:params) do
        {
          "block_type" => {},
        }
      end

      it "should not error" do
        expect(processed_params.result).to eq({
          "block_type" => {},
        })
      end
    end

    context "if the value of the show field is empty" do
      let(:params) do
        {
          "block_type" => {
            "foo" => [
              {
                "nested" => {
                  "show" => "",
                  "value" => "bar",
                },
              },
            ],
          },
        }
      end

      it "should remove the object's fields" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "foo" => [
              {
                "nested" => {},
              },
            ],
          },
        })
      end
    end
  end
end
