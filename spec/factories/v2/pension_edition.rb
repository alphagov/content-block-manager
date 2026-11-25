FactoryBot.define do
  factory :v2_pension_edition, class: "V2::PensionEdition" do
    association :document, factory: :v2_document, block_type: "pension"
    sequence(:title) { |n| "Pension #{n}" }
    description { "A pension description" }
    lead_organisation_id { SecureRandom.uuid }
    creator { association :user }
  end
end
