FactoryBot.define do
  factory :v2_pension_amount, class: "V2::PensionAmount" do
    association :edition, factory: :v2_pension_edition
    amount { BigDecimal("110.60") }
  end
end
