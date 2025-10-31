RSpec.describe Edition::ObjectKey do
  before do
    @details = {}
    @object_type = "my_object_type"
  end

  it "generates a dashed key from a title" do
    normal_key = Edition::ObjectKey.new(@details, @object_type, "My thing")
    expect(normal_key.to_s).to eq("my-thing")
  end

  it "converts underscores to dashed singular" do
    key_from_underscores = Edition::ObjectKey.new(@details, @object_type, "some_other_thing")
    expect(key_from_underscores.to_s).to eq("some-other-thing")
  end

  it "converts plurals to dashed singular" do
    key_from_plural = Edition::ObjectKey.new(@details, @object_type, "some_things")
    expect(key_from_plural.to_s).to eq("some-thing")
  end

  ["", nil, "*#!", "*", "___"].each do |title|
    it "falls back to the object type when title is invalid (#{title.inspect})" do
      invalid_key = Edition::ObjectKey.new(@details, @object_type, title)
      expect(invalid_key.to_s).to eq("my-object-type")
    end
  end

  it "appends a numeric suffix when the generated key already exists" do
    @details = { @object_type => { "my-thing" => "some stuff" } }
    duplicate_key = Edition::ObjectKey.new(@details, @object_type, "My thing")

    expect(duplicate_key.to_s).to eq("my-thing-1")
  end
end
