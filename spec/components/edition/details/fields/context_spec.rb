RSpec.describe Edition::Details::Fields::Context do
  let(:edition) { build(:edition) }
  let(:field) { build(:field, label: "Example") }
  let(:schema) { build(:schema) }

  let(:context) { described_class.new(edition:, field:, schema:) }

  describe "#value" do
    let(:expected_value) { "example" }

    before do
      allow(context).to receive(:value_for_field).and_return(expected_value)
    end

    it "returns the value of the field" do
      expect(context.value).to eq(expected_value)
      expect(context).to have_received(:value_for_field).with(details: edition.details, field:, populate_with_defaults: false)
    end

    context "when populate_with_defaults is true" do
      let(:context) { described_class.new(edition:, field:, schema:, populate_with_defaults: true) }

      it "returns the value of the field" do
        expect(context.value).to eq(expected_value)
        expect(context).to have_received(:value_for_field).with(details: edition.details, field:, populate_with_defaults: true)
      end
    end

    context "when details are provided in the initializer" do
      let(:details) { { "foo" => { "bar" => "baz" } } }
      let(:context) { described_class.new(edition:, field:, schema:, details:) }

      it "uses the provided details" do
        expect(context.value).to eq(expected_value)
        expect(context).to have_received(:value_for_field).with(details:, field:, populate_with_defaults: false)
      end
    end
  end

  describe "#label" do
    context "when the field is required" do
      before do
        expect(field).to receive(:is_required?).and_return(true)
      end

      it "returns the label without an optional prefix" do
        expect(context.label).to eq(field.label)
      end
    end

    context "when the field is not required" do
      before do
        expect(field).to receive(:is_required?).and_return(false)
      end

      it "returns the label with an optional prefix" do
        expect(context.label).to eq("#{field.label} (optional)")
      end
    end
  end

  describe "#name" do
    let(:expected_name) { "example" }

    before do
      allow(field).to receive(:name_attribute).and_return(expected_name)
    end

    it "returns the name of the field" do
      expect(context.name).to eq(expected_name)
      expect(field).to have_received(:name_attribute)
    end
  end

  describe "#id" do
    let(:expected_id) { "example" }

    before do
      allow(field).to receive(:id_attribute).and_return(expected_id)
    end

    it "returns the id of the field" do
      expect(context.id).to eq(expected_id)
      expect(field).to have_received(:id_attribute).with([])
    end

    context "when an index is provided" do
      let(:index) { 3 }
      let(:context) { described_class.new(edition:, field:, schema:, index:) }

      it "sends the index to the id_attribute" do
        expect(context.id).to eq(expected_id)
        expect(field).to have_received(:id_attribute).with([index])
      end
    end

    context "when parent indexes are provided" do
      let(:index) { 3 }
      let(:parent_indexes) { [2] }
      let(:context) { described_class.new(edition:, field:, schema:, index:, parent_indexes:) }

      it "sends the index to the id_attribute" do
        expect(context.id).to eq(expected_id)
        expect(field).to have_received(:id_attribute).with([parent_indexes[0], index])
      end
    end
  end

  describe "#error_items" do
    let(:error_key) { "error_key" }
    let(:errors) { [{ text: "Some error" }] }

    before do
      allow(field).to receive(:error_key).and_return(error_key)
      allow(context).to receive(:errors_for).and_return(errors)
    end

    it "returns the errors for the field" do
      expect(context.error_items).to eq(errors)
      expect(field).to have_received(:error_key).with([])
      expect(context).to have_received(:errors_for).with(edition.errors, error_key.to_sym)
    end

    context "when an index is provided" do
      let(:index) { 3 }
      let(:context) { described_class.new(edition:, field:, schema:, index:) }

      it "sends the index to the error_key" do
        expect(context.error_items).to eq(errors)
        expect(field).to have_received(:error_key).with([index])
      end
    end

    context "when parent indexes are provided" do
      let(:index) { 3 }
      let(:parent_indexes) { [2] }
      let(:context) { described_class.new(edition:, field:, schema:, index:, parent_indexes:) }

      it "sends the index to the id_attribute" do
        expect(context.error_items).to eq(errors)
        expect(field).to have_received(:error_key).with([parent_indexes[0], index])
      end
    end
  end

  describe "#hint_text" do
    let(:expected_hint) { "example" }

    before do
      allow(field).to receive(:hint).and_return(expected_hint)
    end

    it "returns the name of the field" do
      expect(context.hint_text).to eq(expected_hint)
      expect(field).to have_received(:hint)
    end
  end

  describe "#indexes" do
    let(:index) { 3 }
    let(:parent_indexes) { [2, nil, 3] }
    let(:context) { described_class.new(edition:, field:, schema:, index:, parent_indexes:) }

    it "returns the index and parent indexes with any nils removed" do
      expect(context.indexes).to eq([2, 3, 3])
    end
  end
end
