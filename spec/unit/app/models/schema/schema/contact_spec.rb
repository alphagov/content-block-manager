RSpec.describe "contact" do
  let(:schema) { Schema.find_by_block_type("contact") }

  describe "#embeddable_as_block?" do
    subject { schema.embeddable_as_block? }

    it { is_expected.to be_truthy }
  end

  describe "subschemas" do
    describe "email_addresses" do
      let(:subschema) { schema.subschema("email_addresses") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_truthy }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[title email_address subject body description]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title email_address subject body description]) }
      end

      describe "fields" do
        describe "body" do
          let(:field) { subschema.field("body") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end
        end

        describe "description" do
          let(:field) { subschema.field("description") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#character_limit" do
            subject { field.character_limit }

            it { is_expected.to be_nil }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end
      end
    end

    describe "telephones" do
      let(:subschema) { schema.subschema("telephones") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_truthy }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[title description telephone_numbers video_relay_service opening_hours call_charges bsl_guidance]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title description telephone_numbers video_relay_service bsl_guidance opening_hours call_charges]) }
      end

      describe "nested field ordering" do
        describe "video_relay_service" do
          subject { subschema.field("video_relay_service").nested_fields.map(&:name) }

          it { is_expected.to eq(%w[label telephone_number source show]) }
        end

        describe "telephone_numbers" do
          subject { subschema.field("telephone_numbers").nested_fields.map(&:name) }

          it { is_expected.to eq(%w[label telephone_number]) }
        end
      end

      describe "fields" do
        describe "description" do
          let(:field) { subschema.field("description") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#character_limit" do
            subject { field.character_limit }

            it { is_expected.to be_nil }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end

        describe "telephone_numbers" do
          let(:field) { subschema.field("telephone_numbers") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("sortable_array") }
          end
        end

        describe "video_relay_service source" do
          let(:field) { subschema.field("video_relay_service").nested_field("source") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end

        describe "opening_hours opening_hours" do
          let(:field) { subschema.field("opening_hours").nested_field("opening_hours") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end

        describe "bsl_guidance value" do
          let(:field) { subschema.field("bsl_guidance").nested_field("value") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end

        describe "opening_hours" do
          let(:field) { subschema.field("opening_hours") }

          describe "#show_field" do
            subject { field.show_field }

            it "returns the configured show field" do
              expect(subject).not_to be_nil
              expect(subject.name).to eq("show_opening_hours")
            end

            it "returns a hidden field" do
              expect(subject.hidden?).to be_truthy
            end
          end

          describe "show_opening_hours" do
            subject { field.nested_field("show_opening_hours") }

            it "is hidden" do
              expect(subject.hidden?).to be_truthy
            end
          end
        end

        describe "call_charges" do
          let(:field) { subschema.field("call_charges") }

          describe "#show_field" do
            subject { field.show_field }

            it "returns the configured show field" do
              expect(subject).not_to be_nil
              expect(subject.name).to eq("show_call_charges_info_url")
            end

            it "returns a hidden field" do
              expect(subject.hidden?).to be_truthy
            end
          end

          describe "show_call_charges_info_url" do
            subject { field.nested_field("show_call_charges_info_url") }

            it "is hidden" do
              expect(subject.hidden?).to be_truthy
            end
          end
        end

        describe "bsl_guidance" do
          let(:field) { subschema.field("bsl_guidance") }

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

        describe "video_relay_service" do
          let(:field) { subschema.field("video_relay_service") }

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

    describe "addresses" do
      let(:subschema) { schema.subschema("addresses") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_truthy }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[title recipient street_address town_or_city state_or_county postal_code country description]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title recipient street_address town_or_city state_or_county postal_code country description]) }
      end

      describe "fields" do
        describe "country" do
          let(:field) { subschema.field("country") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("country") }
          end
        end

        describe "street_address" do
          let(:field) { subschema.field("street_address") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end
        end

        describe "description" do
          let(:field) { subschema.field("description") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#character_limit" do
            subject { field.character_limit }

            it { is_expected.to be_nil }
          end

          describe "#govspeak_enabled?" do
            subject { field.govspeak_enabled? }

            it { is_expected.to be_truthy }
          end
        end
      end
    end

    describe "contact_links" do
      let(:subschema) { schema.subschema("contact_links") }

      describe "#embeddable_as_block?" do
        subject { subschema.embeddable_as_block? }

        it { is_expected.to be_truthy }
      end

      describe "#block_display_fields" do
        subject { subschema.block_display_fields }

        it { is_expected.to eq(%w[url label description title]) }
      end

      describe "#fields" do
        subject { subschema.fields.map(&:name) }

        it { is_expected.to eq(%w[title label url description]) }
      end

      describe "fields" do
        describe "description" do
          let(:field) { subschema.field("description") }

          describe "#component_name" do
            subject { field.component_name }

            it { is_expected.to eq("textarea") }
          end

          describe "#character_limit" do
            subject { field.character_limit }

            it { is_expected.to be_nil }
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
    describe "#field_ordering_rule" do
      it "uses configured ordering for known top-level fields" do
        expect(schema.field_ordering_rule("title")).to eq(0)
        expect(schema.field_ordering_rule("description")).to eq(1)
        expect(schema.field_ordering_rule("contact_type")).to eq(2)
      end

      it "puts unknown fields at the end" do
        expect(schema.field_ordering_rule("unknown")).to eq(99)
      end
    end

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

  describe "group metadata" do
    it "returns the configured group for contact method subschemas" do
      expect(schema.subschema("addresses").group).to eq("contact_methods")
      expect(schema.subschema("email_addresses").group).to eq("contact_methods")
      expect(schema.subschema("telephones").group).to eq("contact_methods")
      expect(schema.subschema("contact_links").group).to eq("contact_methods")
    end

    it "returns the configured group order for contact method subschemas" do
      expect(schema.subschema("addresses").group_order).to eq(1)
      expect(schema.subschema("email_addresses").group_order).to eq(2)
      expect(schema.subschema("telephones").group_order).to eq(3)
      expect(schema.subschema("contact_links").group_order).to eq(4)
    end
  end

  describe "#subschemas_for_group" do
    it "returns contact methods in configured group order" do
      expect(schema.subschemas_for_group("contact_methods").map(&:id)).to eq(%w[addresses email_addresses telephones contact_links])
    end

    it "returns an empty array when group cannot be found" do
      expect(schema.subschemas_for_group("unknown_group")).to eq([])
    end
  end
end
