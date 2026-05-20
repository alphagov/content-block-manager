RSpec.describe Schema::Field::Translations do
  include ApplicationHelper

  let(:schema) { build(:schema) }
  let(:field) { Schema::Field.new("something", schema) }

  let(:translated_text) { "Translated text" }
  let(:expected_default_values) do
    {
      label: field.name.humanize.gsub("-", " "),
      title: field.name.humanize.gsub("-", " "),
      hint: nil,
    }
  end

  %w[label title hint].each do |method_name|
    describe "##{method_name}" do
      let(:expected_default_value) { expected_default_values[method_name.to_sym] }
      let(:lookup_type) { method_name.pluralize }

      before do
        allow(I18n).to receive(:t).and_return(translated_text)
      end

      context "when the field does not have any parent schemas" do
        it "translates from the correct path" do
          expect(field.send(method_name)).to eq(translated_text)

          expect(I18n).to have_received(:t).with(
            "edition.#{lookup_type}.#{schema.block_type}.#{field.name}",
            default: expected_default_value,
          )
        end
      end

      context "when the field has a parent schema" do
        let(:root_schema) { build(:schema, block_type: "root") }
        let(:schema) { build(:embedded_schema, parent_schema: root_schema, block_type: "schema") }

        it "translates from the correct path" do
          expect(field.send(method_name)).to eq(translated_text)

          expect(I18n).to have_received(:t).with(
            "edition.#{lookup_type}.root.schema.#{field.name}",
            default: expected_default_value,
          )
        end
      end

      context "when the field has multiple parent schemas" do
        let(:root_schema) { build(:schema, block_type: "root") }
        let(:parent_schema) { build(:embedded_schema, parent_schema: root_schema, block_type: "parent") }
        let(:schema) { build(:embedded_schema, parent_schema:, block_type: "schema") }

        it "translates from the correct path" do
          expect(field.send(method_name)).to eq(translated_text)

          expect(I18n).to have_received(:t).with(
            "edition.#{lookup_type}.root.parent.schema.#{field.name}",
            default: expected_default_value,
          )
        end
      end
    end
  end

  describe "#error_message" do
    let(:error_type) { "blank" }

    before do
      allow(I18n).to receive(:t).and_call_original
    end

    context "when the field does not have any parent schemas" do
      it "looks up the error message with the correct path" do
        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.#{error_type}",
          hash_including(
            attribute: field.label.downcase,
            attribute_with_indefinite_article: add_indefinite_article(field.label.downcase),
          ),
        ).and_return("fallback message")

        field.error_message(error_type)

        expect(I18n).to have_received(:t).with(
          "activerecord.errors.models.edition.attributes.#{schema.block_type}.#{field.name}.#{error_type}",
          hash_including(default: "fallback message"),
        )
      end

      it "uses the fallback message when specific message is not found" do
        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.attributes.#{schema.block_type}.#{field.name}.#{error_type}",
          any_args,
        ).and_call_original

        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.#{error_type}",
          hash_including(attribute: field.label),
        ).and_return("Enter a something")

        result = field.error_message(error_type)

        expect(result).to eq("Enter a something")
      end

      it "passes additional arguments to the translation" do
        allow(I18n).to receive(:t).and_return("message with count: 5")

        field.error_message(error_type, count: 5)

        expect(I18n).to have_received(:t).with(
          "activerecord.errors.models.edition.#{error_type}",
          hash_including(attribute: field.label, count: 5),
        )
      end
    end

    context "when the field has a parent schema" do
      let(:root_schema) { build(:schema, block_type: "root") }
      let(:schema) { build(:embedded_schema, parent_schema: root_schema, block_type: "schema") }

      it "looks up the error message with the correct nested path" do
        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.#{error_type}",
          hash_including(
            attribute: field.label.downcase,
            attribute_with_indefinite_article: add_indefinite_article(field.label.downcase),
          ),
        ).and_return("fallback message")

        field.error_message(error_type)

        expect(I18n).to have_received(:t).with(
          "activerecord.errors.models.edition.attributes.root.schema.#{field.name}.#{error_type}",
          hash_including(default: "fallback message"),
        )
      end
    end

    context "when the field has multiple parent schemas" do
      let(:root_schema) { build(:schema, block_type: "root") }
      let(:parent_schema) { build(:embedded_schema, parent_schema: root_schema, block_type: "parent") }
      let(:schema) { build(:embedded_schema, parent_schema:, block_type: "schema") }

      it "looks up the error message with the correct deeply nested path" do
        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.#{error_type}",
          hash_including(
            attribute: field.label.downcase,
            attribute_with_indefinite_article: add_indefinite_article(field.label.downcase),
          ),
        ).and_return("fallback message")

        field.error_message(error_type)

        expect(I18n).to have_received(:t).with(
          "activerecord.errors.models.edition.attributes.root.parent.schema.#{field.name}.#{error_type}",
          hash_including(default: "fallback message"),
        )
      end
    end

    context "when passing interpolation variables" do
      it "passes variables to both primary and fallback translations" do
        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.too_long",
          hash_including(
            attribute: field.label.downcase,
            attribute_with_indefinite_article: add_indefinite_article(field.label.downcase),
            count: 100,
          ),
        ).and_return("fallback message")

        allow(I18n).to receive(:t).with(
          "activerecord.errors.models.edition.attributes.#{schema.block_type}.#{field.name}.too_long",
          hash_including(count: 100),
        ).and_return("custom too long")

        result = field.error_message("too_long", count: 100)

        expect(I18n).to have_received(:t).with(
          "activerecord.errors.models.edition.attributes.#{schema.block_type}.#{field.name}.too_long",
          hash_including(count: 100, default: anything),
        )
        expect(result).to eq("custom too long")
      end
    end
  end
end
