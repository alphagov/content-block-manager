RSpec.describe Edition::ValidatesDetails do
  describe "schema" do
    it "returns a schema" do
      edition = build(:edition, schema: nil)
      schema = build(:schema)

      allow(Schema).to receive(:find_by_block_type).with(edition.block_type).and_return(schema)

      expect(edition.schema).to eq(schema)
    end
  end

  describe "read_attribute_for_validation" do
    it "reads from the details hash if prefixed with `details_`" do
      edition = build(:edition, details: { "foo" => "bar" })

      expect("bar").to eq(edition.read_attribute_for_validation(:details_foo))
    end

    it "reads the attribute directly if not prefixed with `details_`" do
      edition = build(:edition)

      expect(edition.created_at).to eq(edition.read_attribute_for_validation(:created_at))
    end
  end

  describe "human_attribute_name" do
    it "returns the human readable label for a field prefixed with `details_`" do
      expect("Foo").to eq(Edition.human_attribute_name("details_foo"))
    end
  end
end
