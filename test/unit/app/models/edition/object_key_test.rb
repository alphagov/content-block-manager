require "test_helper"

describe Edition::ObjectKey do
  before do
    @details = {}
    @object_type = "my_object_type"
  end

  it "generates a dashed key from a title" do
    normal_key = Edition::ObjectKey.new(@details, @object_type, "My thing")
    assert_equal "my-thing", normal_key.to_s
  end

  it "converts underscores to dashed singular" do
    key_from_underscores = Edition::ObjectKey.new(@details, @object_type, "some_other_thing")
    assert_equal "some-other-thing", key_from_underscores.to_s
  end

  it "converts plurals to dashed singular" do
    key_from_plural = Edition::ObjectKey.new(@details, @object_type, "some_things")
    assert_equal "some-thing", key_from_plural.to_s
  end

  ["", nil, "*#!", "*", "___"].each do |title|
    it "falls back to the object type when title is invalid (#{title.inspect})" do
      invalid_key = Edition::ObjectKey.new(@details, @object_type, title)
      assert_equal "my-object-type", invalid_key.to_s
    end
  end

  it "appends a numeric suffix when the generated key already exists" do
    @details = { @object_type => { "my-thing" => "some stuff" } }
    duplicate_key = Edition::ObjectKey.new(@details, @object_type, "My thing")

    assert_equal "my-thing-1", duplicate_key.to_s
  end
end
