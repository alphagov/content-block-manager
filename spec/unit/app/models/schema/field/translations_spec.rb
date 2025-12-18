RSpec.describe Schema::Field::Translations do
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
end
