RSpec.describe ProcessedParams do
  let(:processed_params) { described_class.new(params, schema) }
  let(:schema) { build(:schema, block_type: "block_type") }

  before do
    allow(schema).to receive(:fields).and_return(fields)
  end

  context "when there is a date field" do
    let(:fields) do
      [
        build(:field, name: "published_at", type: "string", format: "date", show_field: nil, nested_fields: nil),
      ]
    end

    let(:params) do
      {
        "block_type" => {
          "published_at(1i)" => "2024",
          "published_at(2i)" => "01",
          "published_at(3i)" => "15",
        },
      }
    end

    it "combines the multi-part date params into a single value" do
      expect(processed_params.result).to eq({
        "block_type" => {
          "published_at" => "2024-01-15",
        },
      })
    end

    context "when the days/months are not zero-padded" do
      let(:params) do
        {
          "block_type" => {
            "published_at(1i)" => "2024",
            "published_at(2i)" => "1",
            "published_at(3i)" => "1",
          },
        }
      end

      it "pads the date parts with zeroes" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "published_at" => "2024-01-01",
          },
        })
      end
    end
  end

  context "when there is a time field" do
    let(:fields) do
      [
        build(:field, name: "published_at", type: "string", format: "time", show_field: nil, nested_fields: nil),
      ]
    end

    let(:params) do
      {
        "block_type" => {
          "published_at(4i)" => "10",
          "published_at(5i)" => "30",
        },
      }
    end

    it "combines the multi-part time params into a single value" do
      expect(processed_params.result).to eq({
        "block_type" => {
          "published_at" => "10:30",
        },
      })
    end

    context "when the hours and minutes are not zero-padded" do
      let(:params) do
        {
          "block_type" => {
            "published_at(4i)" => "1",
            "published_at(5i)" => "5",
          },
        }
      end

      it "adds zero padding" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "published_at" => "01:05",
          },
        })
      end
    end

    context "when the minutes are missing" do
      let(:params) do
        {
          "block_type" => {
            "published_at(4i)" => "1",
          },
        }
      end

      it "adds zero padding" do
        expect(processed_params.result).to eq({
          "block_type" => {
            "published_at" => "01:00",
          },
        })
      end
    end
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
        build(:field, name: "foo", type: "string", show_field: nil, nested_fields: nil),
      ]
    end

    it "leaves the params unchanged" do
      expect(processed_params.result).to eq(params)
    end
  end

  context "when there are conditionally revealed fields" do
    let(:show_field) { build(:field, name: "show") }
    let(:fields) do
      [
        build(:field, name: "foo", type: "object", show_field:, schema:),
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
    let(:show_field) { build(:field, name: "show") }
    let(:nested_fields) do
      [
        build(:field, name: "nested", type: "object", show_field:, schema:),
      ]
    end
    let(:fields) do
      [
        build(:field, name: "foo", type: "object", show_field: nil, schema:, nested_fields:),
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
    let(:show_field) { build(:field, name: "show") }
    let(:nested_fields) do
      [
        build(:field, name: "nested", type: "object", show_field:),
      ]
    end
    let(:fields) do
      [
        build(:field, name: "foo", type: "array", show_field: nil, schema:, nested_fields:),
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
