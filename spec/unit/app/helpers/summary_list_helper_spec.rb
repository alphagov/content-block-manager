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
end
