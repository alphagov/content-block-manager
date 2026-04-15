FactoryBot.define do
  factory :other_edition, class: "Block::OtherEdition" do
    association :document, factory: :block_document
    title { "Test Other Edition" }
    lead_organisation_id { SecureRandom.uuid }
  end
end
