FactoryBot.define do
  factory :v2_document, class: "V2::Document" do
    sequence(:sluggable_string) { |n| "v2-document-#{n}" }
    block_type { "time_period" }
    testing_artefact { false }

    trait :with_time_period_edition do
      after(:create) do |document|
        create(:v2_time_period_edition, document:)
      end
    end
  end
end
