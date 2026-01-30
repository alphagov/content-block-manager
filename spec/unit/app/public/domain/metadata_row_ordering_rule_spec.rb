RSpec.describe MetadataRowOrderingRule do
  let(:dummy_metadata) do
    [
      { field: "amount", value: "£1000" },
      { field: "title", value: "My Title" },
      { field: "frequency", value: "weekly" },
    ]
  end
  let(:ordering_rule) { described_class.new(field_order:) }
  let(:sorted_metadata) { dummy_metadata.sort_by { |row| ordering_rule.call(row) } }

  describe "#call" do
    context "when field_order is provided" do
      let(:field_order) { %w[frequency title amount] }

      it "should order by the index in field_order" do
        expect(sorted_metadata)
          .to eq([{ field: "frequency", value: "weekly" },
                  { field: "title", value: "My Title" },
                  { field: "amount", value: "£1000" }])
      end
    end

    context "when field_order is **not** provided" do
      let(:field_order) { nil }

      it "should order by title first, then as-provided" do
        expect(sorted_metadata)
          .to eq([{ field: "title", value: "My Title" },
                  { field: "amount", value: "£1000" },
                  { field: "frequency", value: "weekly" }])
      end
    end

    context "when field is named in uppercase" do
      let(:dummy_metadata) do
        [
          { field: "AMOUNT", value: "£1000" },
          { field: "TITLE", value: "My Title" },
          { field: "FREQUENCY", value: "weekly" },
        ]
      end
      context "and field_order is provided" do
        let(:field_order) { %w[frequency title amount] }

        it "should be case insensitive when matching field names" do
          expect(sorted_metadata)
            .to eq([{ field: "FREQUENCY", value: "weekly" },
                    { field: "TITLE", value: "My Title" },
                    { field: "AMOUNT", value: "£1000" }])
        end
      end

      context "and field_order is **not** provided" do
        let(:field_order) { nil }

        it "should be case insensitive when ordering by title" do
          expect(sorted_metadata)
            .to eq([{ field: "TITLE", value: "My Title" },
                    { field: "AMOUNT", value: "£1000" },
                    { field: "FREQUENCY", value: "weekly" }])
        end
      end
    end
  end
end
