RSpec.describe SummaryListHelper do
  include SummaryListHelper

  let(:input) do
    {
      "string_item" => "Item",
      "array_items" => ["Item 1", "Item 2"],
      "array_of_objects_items" => [
        {
          "title" => "Item 1 Title",
          "description" => "Item 1 Description",
        },
        {
          "title" => "Item 2 Title",
          "description" => "Item 2 Description",
        },
      ],
      "object_item" => {
        "title" => "Object Title",
        "description" => "Object Description",
      },
    }
  end

  describe "#first_class_items" do
    it "returns any string items and flattens out non-nested arrays" do
      expected = {
        "string_item" => "Item",
        "array_items" => [
          "Item 1",
          "Item 2",
        ],
      }

      expect(first_class_items(input)).to eq(expected)
    end
  end

  describe "#nested_items" do
    it "returns nested items" do
      expected = {
        "array_of_objects_items" => [
          {
            "title" => "Item 1 Title",
            "description" => "Item 1 Description",
          },
          {
            "title" => "Item 2 Title",
            "description" => "Item 2 Description",
          },
        ],
        "object_item" => {
          "title" => "Object Title",
          "description" => "Object Description",
        },
      }

      expect(expected).to eq(nested_items(input))
    end
  end

  describe "#key_to_label" do
    it "returns a titlelized version of a key without an index" do
      expect("Item").to eq(key_to_label("item", "schema_name"))
    end

    it "returns a titleized version with a count when an index is present" do
      expect("Item 2").to eq(key_to_label("items/1", "schema_name"))
    end

    describe "when there is a translation for the key" do
      it "returns translated key" do
        expect(I18n).to receive(:t).with("edition.labels.schema_name.object_type.item", default: "Item").and_return("Item translated")

        expect("Item translated").to eq(key_to_label("item", "schema_name", "object_type"))
      end
    end
  end

  describe "#key_to_title" do
    it "returns a titlelized version of a key without an index" do
      expect("Item").to eq(key_to_title("item", "schema_name"))
    end

    it "returns a titleized version with a count when an index is present" do
      expect("Item 2").to eq(key_to_title("items/1", "schema_name"))
    end

    describe "when there is a translation for the key" do
      it "returns translated key" do
        expect(I18n).to receive(:t).with("edition.titles.schema_name.object_type.item", default: "Item").and_return("Item translated")

        expect("Item translated").to eq(key_to_title("item", "schema_name", "object_type"))
      end
    end
  end
end
