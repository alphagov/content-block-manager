RSpec.describe DetailsValidator do
  let(:body) do
    {
      "type" => "object",
      "required" => %w[foo bar],
      "additionalProperties" => false,
      "properties" => {
        "foo" => {
          "type" => "string",
          "format" => "email",
        },
        "bar" => {
          "type" => "string",
          "format" => "date",
        },
        "things" => {
          "type" => "object",
          "patternProperties" => {
            "^[a-z0-9]+(?:-[a-z0-9]+)*$" => {
              "type" => "object",
              "required" => %w[my_string],
              "properties" => {
                "my_string" => {
                  "type" => "string",
                },
                "something_else" => {
                  "type" => "string",
                  "format" => "email",
                },
              },
            },
          },
        },
      },
    }
  end

  let(:schema) { build(:schema, body:) }

  it "validates the presence of fields" do
    edition = build(
      :edition,
      :pension,
      details: {
        foo: "",
        bar: "",
      },
      schema:,
    )

    expect(edition).to be_invalid
    errors = edition.errors

    expect_error errors:, key: :details_foo, type: "blank", attribute: "Foo"
    expect_error errors:, key: :details_bar, type: "blank", attribute: "Bar"
  end

  it "validates the format of fields" do
    edition = build(
      :edition,
      :pension,
      details: {
        foo: "dddd",
        bar: "ffff",
      },
      schema:,
    )

    expect(edition).to be_invalid
    errors = edition.errors

    expect(2).to eq(errors.count)
    expect_error errors:, key: :details_foo, type: "invalid", attribute: "Foo"
    expect_error errors:, key: :details_bar, type: "invalid", attribute: "Bar"
  end

  it "validates the presence of nested fields in nested objects" do
    edition = build(
      :edition,
      :pension,
      details: {
        foo: "foo@example.com",
        bar: "2022-01-01",
        things: {
          "something-else": {
            my_string: "",
            something_else: "",
          },
        },
      },
      schema:,
    )

    expect(edition).to be_invalid

    errors = edition.errors

    expect(1).to eq(errors.count)
    expect_error errors:, key: :details_things_my_string, type: "blank", attribute: "My string"
  end

  it "validates the format of nested fields in nested objects" do
    edition = build(
      :edition,
      :pension,
      details: {
        foo: "foo@example.com",
        bar: "2022-01-01",
        things: {
          "something-else": {
            my_string: "something",
            something_else: "Not an email",
          },
        },
      },
      schema:,
    )

    expect(edition).to be_invalid

    errors = edition.errors

    expect_error errors:, key: :details_things_something_else, type: "invalid", attribute: "Something else"
  end

  describe "validating against a regular expression" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[foo],
        "additionalProperties" => false,
        "properties" => {
          "foo" => {
            "type" => "string",
            "pattern" => "£[0-9]+\\.[0-9]+",
          },
        },
      }
    end

    it "returns an error if the pattern is incorrect" do
      edition = build(
        :edition,
        :pension,
        details: {
          foo: "1234",
        },
        schema:,
      )

      expect(edition).to be_invalid
      errors = edition.errors
      expect_error errors:, key: :details_foo, type: "invalid", attribute: "Foo"
    end
  end

  describe "validating against arrays" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[foo bar],
        "additionalProperties" => false,
        "properties" => {
          "things" => {
            "type" => "object",
            "patternProperties" => {
              "^[a-z0-9]+(?:-[a-z0-9]+)*$" => {
                "type" => "object",
                "properties" => {
                  "array_of_objects" => {
                    "type" => "array",
                    "items" => {
                      "type" => "object",
                      "required" => %w[foo],
                      "properties" => {
                        "foo" => {
                          "type" => "string",
                          "pattern" => "valid",
                        },
                        "bar" => {
                          "type" => "string",
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    it "returns an error if a required item is missing in an array of objects" do
      edition = build(
        :edition,
        :pension,
        details: {
          foo: "foo@example.com",
          bar: "2022-01-01",
          things: {
            "something-else": {
              array_of_objects: [
                {
                  foo: "valid",
                  bar: "something",
                },
                {
                  foo: "",
                  bar: "something",
                },
              ],
            },
          },
        },
        schema:,
      )

      expect(edition).to be_invalid
      errors = edition.errors
      expect_error errors:, key: :details_things_array_of_objects_1_foo, type: "blank", attribute: "Foo"
    end

    it "returns an error if an item is invalid in an array of objects" do
      edition = build(
        :edition,
        :pension,
        details: {
          foo: "foo@example.com",
          bar: "2022-01-01",
          things: {
            "something-else": {
              array_of_objects: [
                {
                  foo: "not correct",
                  bar: "something",
                },
                {
                  foo: "",
                  bar: "something",
                },
              ],
            },
          },
        },
        schema:,
      )

      expect(edition).to be_invalid
      errors = edition.errors
      expect_error errors:, key: :details_things_array_of_objects_0_foo, type: "invalid", attribute: "Foo"
    end
  end

  describe "#translate_error" do
    let(:validator) { DetailsValidator.new }

    it "attempts to find a translation for a field when validation fails" do
      attribute = "foo"
      type = "bar"

      expect(I18n).to receive(:t).with(
        "activerecord.errors.models.edition.attributes.#{attribute}.#{type}",
        attribute: attribute.humanize,
        default: ["activerecord.errors.models.edition.#{type}".to_sym],
      ).and_return("translated")

      expect(validator.translate_error(type, attribute)).to eq("translated")
    end
  end

  describe "#key_with_optional_prefix" do
    let(:validator) { DetailsValidator.new }

    it "returns the key when an error does not have a data_pointer" do
      expect(validator.key_with_optional_prefix({}, "my_key")).to eq("my_key")
    end

    it "returns the key when a reference has a data_pointer but no schema_pointer" do
      error = { "data_pointer" => "/foo/something" }
      expect(validator.key_with_optional_prefix(error, "my_key")).to eq("foo_something_my_key")
    end

    it "returns the key when a reference has a data_pointer and the schema_pointer does not include a pattern property" do
      error = { "data_pointer" => "/foo/something", "schema_pointer" => "/properties/things/foo/something" }
      expect(validator.key_with_optional_prefix(error, "my_key")).to eq("foo_something_my_key")
    end

    it "returns the key without a reference to the embedded object when a data_pointer is present" do
      error = { "data_pointer" => "/foo/something", "schema_pointer" => "/properties/things/patternProperties/^[a-z0-9]+(?:-[a-z0-9]+)*$" }
      expect(validator.key_with_optional_prefix(error, "my_key")).to eq("foo_my_key")
    end

    it "returns the key without a reference to the embedded object when a data_pointer is present and nested" do
      error = { "data_pointer" => "/foo/something/field", "schema_pointer" => "/properties/things/patternProperties/^[a-z0-9]+(?:-[a-z0-9]+)*$" }
      expect(validator.key_with_optional_prefix(error, "my_key")).to eq("foo_field_my_key")
    end
  end

  def expect_error(errors:, key:, type:, attribute:)
    expect(errors[key]).to eq([I18n.t("activerecord.errors.models.edition.#{type}", attribute:)])
  end
end
