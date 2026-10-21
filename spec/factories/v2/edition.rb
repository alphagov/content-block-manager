FactoryBot.define do
  factory :v2_edition, class: "V2::Edition" do
    sequence(:title) { |n| "V2 edition title #{n}" }

    state { "draft" }

    association :document, factory: :v2_document

    lead_organisation_id { SecureRandom.uuid }

    association :creator, factory: :user

    trait :published do
      state { "published" }
    end
  end
end
