require "test_helper"

class ValidatesDetailsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "schema" do
    it "returns a schema" do
      edition = build(:edition, schema: nil)
      schema = build(:schema)

      schema_mock = Minitest::Mock.new
      schema_mock.expect :call, schema, [edition.block_type]

      Schema.stub :find_by_block_type, schema_mock do
        assert_equal schema, edition.schema
      end

      schema_mock.verify
    end
  end

  describe "read_attribute_for_validation" do
    it "reads from the details hash if prefixed with `details_`" do
      edition = build(:edition, details: { "foo" => "bar" })

      assert_equal edition.read_attribute_for_validation(:details_foo), "bar"
    end

    it "reads the attribute directly if not prefixed with `details_`" do
      edition = build(:edition)

      assert_equal edition.read_attribute_for_validation(:created_at), edition.created_at
    end
  end

  describe "human_attribute_name" do
    it "returns the human readable label for a field prefixed with `details_`" do
      assert_equal Edition.human_attribute_name("details_foo"), "Foo"
    end
  end
end
