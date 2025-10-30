FactoryBot.define do
  factory :document, class: "Document" do
    sequence(:content_id) { SecureRandom.uuid }
    sluggable_string { "factory-example-title" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    latest_edition_id { nil }
    live_edition_id { nil }
    block_type { "pension" }

    transient do
      schema { nil }
    end

    Schema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
        schema { build(:schema, block_type: type) }
      end
    end

    after(:build) do |document, evaluator|
      allow(document).to receive(:schema).and_return(evaluator.schema)
    end
  end
end
