require "test_helper"

class DiffItemTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".from_hash" do
    it "returns a hash of typed objects from a hash" do
      hash = {
        "foo" => { "previous_value" => "bar", "new_value" => "baz" },
        "bar" => { "previous_value" => "", "new_value" => "something" },
        "deeply" => {
          "nested" => {
            "thing" => { "previous_value" => "one thing", "new_value" => "something else" },
          },
        },
      }

      expected = {
        "foo" => DiffItem.new(previous_value: "bar", new_value: "baz"),
        "bar" => DiffItem.new(previous_value: nil, new_value: "something"),
        "deeply" => {
          "nested" => {
            "thing" => DiffItem.new(previous_value: "one thing", new_value: "something else"),
          },
        },
      }

      assert_equal expected, DiffItem.from_hash(hash)
    end
  end
end
