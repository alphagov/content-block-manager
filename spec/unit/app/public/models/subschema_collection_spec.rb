RSpec.describe SubschemaCollection do
  let(:subschemas) { [*group_1_subschemas, *group_2_subschemas, *subschemas_without_groups] }
  let(:collection) { SubschemaCollection.new(subschemas) }

  let(:group_1_subschemas) do
    [
      double(:subschema, group: "group_1"),
      double(:subschema, group: "group_1"),
    ]
  end

  let(:group_2_subschemas) do
    [
      double(:subschema, group: "group_2"),
      double(:subschema, group: "group_2"),
      double(:subschema, group: "group_2"),
    ]
  end

  let(:subschemas_without_groups) do
    [
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
    ]
  end

  describe "#grouped" do
    it "returns all subschemas with a group, grouped by the :group field" do
      expect(collection.grouped).to eq({ "group_1" => group_1_subschemas, "group_2" => group_2_subschemas })
    end
  end

  describe "#ungrouped" do
    it "returns all ungrouped subschemas" do
      expect(collection.ungrouped).to eq(subschemas_without_groups)
    end
  end
end
