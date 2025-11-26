FactoryBot.define do
  factory :document, class: "Document" do
    sequence(:content_id) { SecureRandom.uuid }
    sluggable_string { "factory-example-title" }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
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
      document.stubs(:schema).returns(evaluator.schema)
    end
  end
end
