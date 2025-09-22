require "test_helper"

class TranslationHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include TranslationHelper

  describe "humanized_label" do
    describe "when there is a 'root object'" do
      it "prepends the root object to the 'relative label key'" do
        I18n.expects(:t)
          .with(
            "edition.labels.schema.root_object.nested_object.field_name",
            default: "Nested object.field name",
          )
          .returns("Field label")

        assert_equal(
          "Field label",
          humanized_label(schema_name: "schema", relative_key: "nested_object.field_name", root_object: "root_object"),
        )
      end
    end

    describe "when there is not a 'root object'" do
      it "uses only the 'relative label key" do
        I18n.expects(:t)
          .with(
            "edition.labels.schema.nested_object.field_name",
            default: "Nested object.field name",
          )
          .returns("Field label")

        assert_equal(
          "Field label",
          humanized_label(schema_name: "schema", relative_key: "nested_object.field_name"),
        )
      end
    end

    it "strips hyphens from the 'default' passed to I18n.t" do
      I18n.expects(:t)
        .with(
          "edition.labels.schema.nested_object.field-name",
          default: "Nested object.field name",
        )
        .returns("Field label")

      assert_equal(
        "Field label",
        humanized_label(schema_name: "schema", relative_key: "nested_object.field-name"),
      )
    end
  end

  describe "translated_value" do
    it "calls translation config with value" do
      I18n.expects(:t)
          .with("edition.values.key.field value", default: ["edition.values.field value".to_sym, "field value"])
          .returns("field value")

      assert_equal "field value", translated_value("key", "field value")
    end
  end

  describe "#label_for_title" do
    let(:block_type) { "something" }
    let(:default_title) { "Default title" }
    let(:alternative_title) { "Alternative title" }

    before do
      I18n.stubs(:t).with("activerecord.attributes.edition/document.title.default")
          .returns(default_title)
    end

    it "returns an alternative label for the block type if it exists" do
      I18n.stubs(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .returns(alternative_title)

      assert_equal alternative_title, label_for_title(block_type)
    end

    it "returns the default for the block type if it does not exist" do
      I18n.stubs(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .returns(nil)

      assert_equal default_title, label_for_title(block_type)
    end
  end

  describe "#hint_text" do
    let(:schema) { stub(:schema, block_type: "schema") }
    let(:subschema) { stub(:subschema, block_type: "subschema") }
    let(:field) { stub(:field, name: "field") }

    let(:response) { "RESPONSE" }

    it "fetches a translation when subschema is nil" do
      I18n.expects(:t).with("edition.hints.schema.field", default: nil).returns(response)

      assert_equal hint_text(schema:, subschema: nil, field:), response
    end

    it "fetches a translation when subschema is present" do
      I18n.expects(:t).with("edition.hints.schema.subschema.field", default: nil).returns(response)

      assert_equal hint_text(schema:, subschema:, field:), response
    end
  end
end
