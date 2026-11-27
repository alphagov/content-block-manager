RSpec.describe V2::PensionEdition, type: :model do
  let(:creator) { create(:user) }

  describe "inheritance" do
    it "inherits from V2::Edition" do
      expect(described_class.superclass).to eq(V2::Edition)
    end

    it "uses STI with correct type value" do
      document = V2::Document.create!(sluggable_string: "test-block", block_type: "pension")
      edition = described_class.create!(
        document: document,
        title: "Test pension",
        lead_organisation_id: SecureRandom.uuid,
        creator:,
      )

      expect(edition.type).to eq("V2::PensionEdition")
      expect(V2::Edition.find(edition.id)).to be_a(V2::PensionEdition)
    end
  end

  describe "validations" do
    it "inherits title presence validation from V2::Edition" do
      edition = described_class.new(title: nil, lead_organisation_id: SecureRandom.uuid)
      expect(edition).not_to be_valid
      expect(edition.errors[:title]).to include("cannot be blank")
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:pension_amount).class_name("V2::PensionAmount").dependent(:destroy) }
  end

  describe "nested attributes" do
    it "accepts nested attributes for pension_amount" do
      edition = create(:v2_pension_edition)

      edition.update!(
        pension_amount_attributes: {
          amount: "99.99",
        },
      )

      expect(edition.pension_amount).to be_present
      expect(edition.pension_amount.amount).to eq(BigDecimal("99.99"))
    end
  end

  describe "#to_details" do
    it "returns hash with description and the pension amount" do
      pension_amount = build(:v2_pension_amount, amount: BigDecimal("90.11"))
      edition = build(:v2_pension_edition,
                      description: "State pension 2025/26",
                      pension_amount:)

      expect(edition.to_details).to eq({
        "description" => "State pension 2025/26",
        "amount" => "90.11",
      })
    end

    it "retains both decimal places in the amount value" do
      pension_amount = build(:v2_pension_amount, amount: BigDecimal("90.10"))
      edition = build(:v2_pension_edition,
                      pension_amount:)

      expect(edition.to_details["amount"]).to eq("90.10")
    end

    context "when #description is defined and #pension_amount is nil" do
      let(:edition) { build(:v2_pension_edition, description: "Pension 2025/26", pension_amount: nil) }

      it "returns hash with only description" do
        expect(edition.to_details).to eq({
          "description" => "Pension 2025/26",
        })
      end
    end

    context "when #pension_amount is defined and #description is nil" do
      let(:pension_amount) { build(:v2_pension_amount, amount: BigDecimal("90.10")) }
      let(:edition) do
        build(:v2_pension_edition,
              description: nil,
              pension_amount:)
      end

      it "returns hash with only pension amount" do
        expect(edition.to_details).to eq({
          "amount" => "90.10",
        })
      end
    end

    context "when both #description and #pension_amount are nil" do
      let(:edition) { build(:v2_pension_edition, pension_amount: nil, description: nil) }

      it "returns an empty hash" do
        expect(edition.to_details).to eq({})
      end
    end

    context "when both #description and #pension_amount#amount are nil" do
      let(:pension_amount) { build(:v2_pension_amount, amount: nil) }
      let(:edition) { build(:v2_pension_edition, pension_amount: pension_amount, description: nil) }

      it "returns an empty hash" do
        expect(edition.to_details).to eq({})
      end
    end
  end
end
