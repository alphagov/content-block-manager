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

  let(:input_combined) do
    {
      "string_item" => { "published" => "Item", "new" => "Item" },
      "array_items" => [{ "published" => "Item 1", "new" => "Item 1" },
                        { "published" => "Item 2", "new" => "Item 2" }],
      "array_of_objects_items" => [
        {
          "title" => { "published" => "Item 1 Title" },
          "description" => { "new" => "Item 1 Title" },
        },
      ],
      "object_item" => {
        "title" => { "published" => "Object Title", "new" => "Object Title" },
        "description" => { "published" => "Object Description", "new" => "Object Description" },
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

    context "when provided with combined edition details" do
      it "should return any direct child items with a 'published' or 'new' child key" do
        expected = { "string_item" => { "new" => "Item", "published" => "Item" } }
        expect(first_class_items(input_combined)).to eq(expected)
      end
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

      expect(nested_items(input)).to eq(expected)
    end

    context "when provided with combined edition details" do
      it "should not return items with a 'published' or 'new' key as 'nested items'" do
        expected = { "array_items" =>
                     [{ "published" => "Item 1", "new" => "Item 1" },
                      { "published" => "Item 2", "new" => "Item 2" }],
                     "array_of_objects_items" =>
                     [{ "description" => { "new" => "Item 1 Title" }, "title" => { "published" => "Item 1 Title" } }],
                     "object_item" =>
                     { "description" =>
                       { "new" => "Object Description", "published" => "Object Description" },
                       "title" =>
                       { "new" => "Object Title", "published" => "Object Title" } } }

        expect(nested_items(input_combined)).to eq(expected)
      end
    end
  end
end
