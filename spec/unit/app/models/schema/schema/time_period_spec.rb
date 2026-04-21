RSpec.describe "time_period" do
  let(:schema) { Schema.find_by_block_type("time_period") }

  describe "#embeddable_as_block?" do
    subject { schema.embeddable_as_block? }

    it { is_expected.to be_truthy }
  end

  describe "subschemas" do
    describe "date_range" do
      let(:subschema) { schema.subschema("date_range") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_truthy }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[start end]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[start end]) }
      end

      describe "fields" do
        describe "start" do
          let(:field) { subschema.field("start") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("date_time") }
          end
        end

        describe "end" do
          let(:field) { subschema.field("end") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("date_time") }
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
