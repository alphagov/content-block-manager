RSpec.describe BlockContent do
  context "when used with an *object_title* to identify a particular object" do
    let(:subschema) { build(:schema) }
    let(:schema) { build(:schema) }
    let(:document) { build(:document) }
    let(:display_fields) { %w[amount] }
    let(:edition) do
      build(:edition,
            document: document,
            details: {
              "content_block_block_type" => {
                "my_rate" => {
                  "title" => "my title",
                  "frequency" => "weekly",
                  "amount" => "£1000",
                },
              },
            })
    end
    let(:content_block) { build(:content_block, schema: subschema, edition:) }
    let(:block_content) { described_class.new(content_block, subschema) }

    before do
      allow(document).to receive(:schema).and_return(schema)
      allow(schema).to receive(:subschema).with("content_block_block_type").and_return(subschema)
      allow(subschema).to receive(:block_display_fields).and_return(display_fields)
    end

    describe "#metadata" do
      it "should return the fields that are not defined as block-level (display) fields" do
        expect(block_content.metadata("my_rate")).to eq({ "frequency" => "weekly", "title" => "my title" })
      end

      context "when block is not defined" do
        let(:content_block) { nil }

        it "should return nil" do
          expect(block_content.metadata("my_rate")).to be_nil
        end
      end
    end

    describe "#fields" do
      it "should return the fields defined as block-level (display) fields" do
        expect(block_content.fields("my_rate")).to eq({ "amount" => "£1000" })
      end

      context "when block is not defined" do
        let(:content_block) { nil }

        it "should return nil" do
          expect(block_content.fields("my_rate")).to be_nil
        end
      end
    end
  end

  context "when used for a 1:1 subschema where no *object_title* is used" do
    let(:embedded_object_details) do
      {
        "start" => { "date" => "2025-04-06", "time" => "00:00" },
        "end" => { "date" => "2026-04-05", "time" => "23:52" },
      }
    end

    let(:edition) do
      build(:edition, :time_period, details: {
        "date_range" => embedded_object_details,
      })
    end

    let(:parent_schema) { double("time period schema", subschema: date_range_subschema) }

    let(:date_range_subschema) do
      double(
        "date range subschema",
        id: "date_range",
        field_ordering_rule: 1,
      )
    end

    let(:block_content) { described_class.new(edition, date_range_subschema) }

    before do
      allow(edition.document).to receive(:schema).and_return(parent_schema)
      allow(parent_schema).to receive(:subschema).and_return(date_range_subschema)
    end

    describe "#metadata" do
      context "when fields are configured for block display" do
        before do
          allow(date_range_subschema).to receive(:block_display_fields).and_return(%w[start end])
        end

        it "excludes those fields from the metadata" do
          expect(block_content.metadata).to eq({})
        end
      end

      context "when fields are NOT configured for block display" do
        before do
          allow(date_range_subschema).to receive(:block_display_fields).and_return(%w[])
        end

        it "includes those fields in the metadata" do
          expect(block_content.metadata).to eq(embedded_object_details)
        end
      end
    end

    describe "#fields" do
      context "when fields are configured for block display" do
        before do
          allow(date_range_subschema).to receive(:block_display_fields).and_return(%w[start end])
        end

        it "includes those fields, ordering according to the Schema#field_ordering_rule as per config" do
          expect(block_content.fields).to eq(
            "end" => { "date" => "2026-04-05", "time" => "23:52" },
            "start" => { "date" => "2025-04-06", "time" => "00:00" },
          )
        end
      end

      context "when fields are NOT configured for block display" do
        before do
          allow(date_range_subschema).to receive(:block_display_fields).and_return(%w[])
        end

        it "excludes thos fields" do
          expect(block_content.fields).to eq({})
        end
      end
    end
  end
end
