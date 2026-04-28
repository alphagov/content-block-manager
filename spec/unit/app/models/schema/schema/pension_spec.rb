RSpec.describe "pension" do
  let(:schema) { Schema.find_by_block_type("pension") }

  describe "#embeddable_as_block?" do
    subject { schema.embeddable_as_block? }

    it { is_expected.to be_falsey }
  end

  describe "subschemas" do
    describe "rates" do
      let(:subschema) { schema.subschema("rates") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_falsey }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[amount]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title amount frequency description]) }
      end

      describe "fields" do
        describe "description" do
          let(:field) { subschema.field("description") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end
      end
    end
  end

  describe "fields" do
    describe "description" do
      let(:field) { schema.field("description") }

      describe "#component_name" do
        subject { field.component_name }

        it { is_expected.to eq("textarea") }
      end

      describe "#character_limit" do
        subject { field.character_limit }

        it { is_expected.to eq(165) }
      end

      describe "#govspeak_enabled?" do
        subject { field.govspeak_enabled? }

        it { is_expected.to be_truthy }
      end
    end
  end
end
