FactoryBot.define do
  factory :block_document, class: "Block::Document" do
    sequence(:sluggable_string) { |n| "block-document-#{n}" }
    block_type { "time_period" }
    testing_artefact { false }

    trait :with_time_period_edition do
      after(:create) do |document|
        create(:block_time_period_edition, block_document: document)
      end
    end
  end
end
