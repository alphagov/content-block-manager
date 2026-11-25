RSpec.describe V2::PensionAmount, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:edition).class_name("V2::PensionEdition") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end
end
