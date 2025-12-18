RSpec.describe FormHelper, type: :helper do
  describe "#ga4_data_attributes" do
    let(:document) { double(block_type: "email_address", is_new_block?: false) }
    let(:edition) { double(document: document) }
    let(:section) { "details" }

    let(:result) { ga4_data_attributes(edition: edition, section: section) }

    it "returns correctly structured data attributes with edition and section" do
      expect(result[:data][:module]).to eq("ga4-form-tracker")
      expect(result[:data][:ga4_form][:type]).to eq("Content Block")
      expect(result[:data][:ga4_form][:tool_name]).to eq("email_address")
      expect(result[:data][:ga4_form][:event_name]).to eq("update")
      expect(result[:data][:ga4_form][:section]).to eq("details")
    end

    describe "when an edition's document is nil" do
      let(:document) { nil }

      it "returns event_name as 'create'" do
        expect(result[:data][:ga4_form][:event_name]).to eq("create")
      end

      it "returns nil for tool_name" do
        expect(result[:data][:ga4_form][:tool_name]).to be_nil
      end

      describe "when a block_type is given" do
        let(:block_type) { "contact_information" }
        let(:result) { ga4_data_attributes(edition: edition, section: section, block_type: block_type) }

        it "the block type as the tool_name" do
          expect(result[:data][:ga4_form][:tool_name]).to eq("contact_information")
        end
      end
    end

    describe "when an edition is nil" do
      let(:edition) { nil }

      it "returns event_name as 'create'" do
        expect(result[:data][:ga4_form][:event_name]).to eq("create")
      end

      it "returns nil for tool_name" do
        expect(result[:data][:ga4_form][:tool_name]).to be_nil
      end
    end

    describe "when an edition's document is a new block" do
      let(:document) { double(block_type: "email_address", is_new_block?: true) }

      it "returns event_name as 'create'" do
        result = ga4_data_attributes(edition: edition, section: section)

        expect(result[:data][:ga4_form][:event_name]).to eq("create")
      end
    end
  end

  describe "#event_name_for_edition" do
    let(:edition) { double(document: document) }

    describe "when an edition's document is nil" do
      let(:document) { nil }

      it "returns 'create'" do
        edition = double(document: nil)

        result = event_name_for_edition(edition)

        expect(result).to eq("create")
      end
    end

    describe "when an edition is nil" do
      let(:edition) { nil }

      it "returns 'create'" do
        result = event_name_for_edition(edition)

        expect(result).to eq("create")
      end
    end

    describe "when an edition's document is a new block" do
      let(:document) { double(is_new_block?: true) }

      it "returns 'create'" do
        edition = double(document: nil)

        result = event_name_for_edition(edition)

        expect(result).to eq("create")
      end
    end

    describe "when an edition's document is not a new block" do
      let(:document) { double(is_new_block?: false) }

      it "returns 'create'" do
        edition = double(document: nil)

        result = event_name_for_edition(edition)

        expect(result).to eq("create")
      end
    end
  end

  describe "#value_for_field" do
    let(:field1) { double(name: "foo", default_value: nil) }
    let(:field2) { double(name: "bar", default_value: "baz") }
    let(:details) { { "foo" => "bar" } }

    describe "when populate_with_defaults is true" do
      let(:populate_with_defaults) { true }

      it "returns the value for the field if present" do
        expect(value_for_field(details:, field: field1, populate_with_defaults:)).to eq("bar")
      end

      it "returns the default value for the field if not present" do
        expect(value_for_field(details:, field: field2, populate_with_defaults:)).to eq("baz")
      end

      describe "when details is nil" do
        let(:details) { nil }

        it "returns nil if there is no default value" do
          expect(value_for_field(details: details, field: field1, populate_with_defaults:)).to be_nil
        end

        it "returns the default value for the field" do
          expect(value_for_field(details:, field: field2, populate_with_defaults:)).to eq("baz")
        end
      end
    end

    describe "when populate_with_defaults is false" do
      let(:populate_with_defaults) { false }

      it "returns the value for the field if present" do
        expect(value_for_field(details:, field: field1, populate_with_defaults:)).to eq("bar")
      end

      it "returns nil for the field if not present" do
        expect(value_for_field(details: details, field: field2, populate_with_defaults:)).to be_nil
      end

      describe "when details is nil" do
        let(:details) { nil }

        it "returns nil if there is no default value" do
          expect(value_for_field(details: details, field: field1, populate_with_defaults:)).to be_nil
        end

        it "returns nil if there is a default value" do
          expect(value_for_field(details: details, field: field2, populate_with_defaults:)).to be_nil
        end
      end
    end
  end

  describe "#component_for_field" do
    it "initializes a field's component with the correct arguments" do
      args = { argument: "value", empty: nil }
      component_class = double(:component_class)
      field = build(:field)

      allow(field).to receive(:component_class).and_return(component_class)
      allow(component_class).to receive(:new).and_return("RESPONSE")

      expect(component_for_field(field, args)).to eq("RESPONSE")

      expect(component_class).to have_received(:new).with(argument: "value")
    end
  end
end
