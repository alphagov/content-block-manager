RSpec.describe TranslationHelper do
  include TranslationHelper

  describe "humanized_label" do
    describe "when there is a 'root object'" do
      it "prepends the root object to the 'relative label key'" do
        allow(I18n).to receive(:t)
          .with(
            "edition.labels.schema.root_object.nested_object.field_name",
            default: "Nested object.field name",
          )
          .and_return("Field label")

        expect(
          humanized_label(schema_name: "schema", relative_key: "nested_object.field_name", root_object: "root_object"),
        ).to eq("Field label")
      end
    end

    describe "when there is not a 'root object'" do
      it "uses only the 'relative label key" do
        allow(I18n).to receive(:t)
          .with(
            "edition.labels.schema.nested_object.field_name",
            default: "Nested object.field name",
          )
          .and_return("Field label")

        expect(humanized_label(schema_name: "schema", relative_key: "nested_object.field_name")).to eq("Field label")
      end
    end

    it "strips hyphens from the 'default' passed to I18n.t" do
      allow(I18n).to receive(:t)
        .with(
          "edition.labels.schema.nested_object.field-name",
          default: "Nested object.field name",
        )
        .and_return("Field label")

      expect(humanized_label(schema_name: "schema", relative_key: "nested_object.field-name")).to eq("Field label")
    end
  end

  describe "translated_value" do
    it "calls translation config with value" do
      allow(I18n).to receive(:t)
          .with("edition.values.key.field value", default: ["edition.values.field value".to_sym, "field value"])
          .and_return("field value")

      expect(translated_value("key", "field value")).to eq("field value")
    end
  end

  describe "#label_for_title" do
    let(:block_type) { "something" }
    let(:default_title) { "Default title" }
    let(:alternative_title) { "Alternative title" }

    before do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.default")
          .and_return(default_title)
    end

    it "returns an alternative label for the block type if it exists" do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .and_return(alternative_title)

      expect(label_for_title(block_type)).to eq(alternative_title)
    end

    it "returns the default for the block type if it does not exist" do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .and_return(nil)

      expect(label_for_title(block_type)).to eq(default_title)
    end
  end

  describe "#hint_text" do
    let(:schema) { double(:schema, block_type: "schema") }
    let(:subschema) { double(:subschema, block_type: "subschema") }
    let(:field) { build(:field, name: "field") }

    let(:response) { "RESPONSE" }

    it "fetches a translation when subschema is nil" do
      allow(I18n).to receive(:t).with("edition.hints.schema.field", default: nil).and_return(response)

      expect(response).to eq(hint_text(schema:, subschema: nil, field:))
    end

    it "fetches a translation when subschema is present" do
      allow(I18n).to receive(:t).with("edition.hints.schema.subschema.field", default: nil).and_return(response)

      expect(response).to eq(hint_text(schema:, subschema:, field:))
    end
  end
end
