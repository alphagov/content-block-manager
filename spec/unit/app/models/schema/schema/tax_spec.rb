RSpec.describe "tax" do
  let(:schema) { Schema.find_by_block_type("tax") }

  describe "#embeddable_as_block?" do
    subject { schema.embeddable_as_block? }

    it { is_expected.to be_falsey }
  end

  describe "subschemas" do
    describe "things_taxed" do
      let(:subschema) { schema.subschema("things_taxed") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_falsey }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[rates]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title type rates]) }
      end

      describe "nested field ordering" do
        describe "rates" do
          subject { subschema.field("rates").nested_fields.map(&:name) }

          it { is_expected.to eq(%w[name value bands]) }
        end

        describe "rates bands" do
          subject { subschema.field("rates").nested_field("bands").nested_fields.map(&:name) }

          it { is_expected.to eq(%w[name lower_threshold upper_threshold]) }
        end

        describe "rates bands lower_threshold" do
          let(:field) { subschema.field("rates").nested_field("bands").nested_field("lower_threshold") }

          describe "#show_field" do
            subject { field.show_field }

            it "returns the configured show field" do
              expect(subject).not_to be_nil
              expect(subject.name).to eq("show")
            end

            it "returns a hidden field" do
              expect(subject.hidden?).to be_truthy
            end
          end

          describe "show" do
            subject { field.nested_field("show") }

            it "is hidden" do
              expect(subject.hidden?).to be_truthy
            end
          end
        end

        describe "rates bands upper_threshold" do
          let(:field) { subschema.field("rates").nested_field("bands").nested_field("upper_threshold") }

          describe "#show_field" do
            subject { field.show_field }

            it "returns the configured show field" do
              expect(subject).not_to be_nil
              expect(subject.name).to eq("show")
            end

            it "returns a hidden field" do
              expect(subject.hidden?).to be_truthy
            end
          end

          describe "show" do
            subject { field.nested_field("show") }

            it "is hidden" do
              expect(subject.hidden?).to be_truthy
            end
          end
        end
      end
    end
  end

  describe "#fields" do
    subject { schema.fields.map(&:name) }

    it { is_expected.to eq(%w[abbreviation synonym tax_type description]) }
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
