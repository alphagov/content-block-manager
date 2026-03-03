RSpec.describe DetailsValidator do
  describe "pension schema" do
    let(:schema_body) { JSON.parse(File.read(Rails.root.join("app/models/schema/definitions/pension.json"))) }
    let(:schema) { Schema.new("content_block_pension", schema_body) }

    let(:document) { build(:document, schema:) }

    let(:amount) { "£320.00" }
    let(:frequency) { "a week" }

    let(:rate) do
      {
        title: "Some title",
        amount:,
        description: "Some description",
        frequency:,
      }
    end

    let(:details) do
      {
        description: "test description",
        rates: {
          rate:,
        },
      }
    end

    subject { build(:edition, schema: schema, details:, document:) }

    before do
      subject.valid?
    end

    let(:errors) { subject.errors }

    context "when the details are valid" do
      it { is_expected.to be_valid }
    end

    context "when the amount does not have a decimal point" do
      let(:amount) { "£320" }

      it { is_expected.to be_valid }
    end

    context "when the amount is not a number" do
      let(:amount) { "AMOUNT" }

      it { is_expected.to_not be_valid }

      it "adds an error to the amount field" do
        expect(errors[:details_rates_amount]).to include("Invalid Amount")
      end
    end

    context "when amount is blank" do
      let(:amount) { "" }

      it { is_expected.to_not be_valid }

      it "adds an error to the amount field" do
        expect(errors[:details_rates_amount]).to include("Amount cannot be blank")
      end
    end

    context "when frequency is blank" do
      let(:frequency) { "" }

      it { is_expected.to_not be_valid }

      it "adds an error to the amount field" do
        expect(errors[:details_rates_frequency]).to include("Frequency cannot be blank")
      end
    end
  end
end
