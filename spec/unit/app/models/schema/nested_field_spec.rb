RSpec.describe Schema::Field::NestedField do
  describe "NestedField" do
    it "can be created without passing a 'default_value' argument" do
      nested_field = Schema::Field::NestedField.new(
        name: "address_line_1",
        format: "string",
        enum_values: [],
      )

      expect(nested_field.name).to eq("address_line_1")
      expect(nested_field.format).to eq("string")
      expect(nested_field.enum_values).to eq([])
      assert_nil(nested_field.default_value)
    end
  end
end
