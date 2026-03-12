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

    Schema.supported_block_types.each do |block_type|
      trait block_type.to_sym do
        block_type { block_type }
        schema { build(:schema, block_type:) }
      end
    end

    before(:create) do |document, _evaluator|
      # this reproduces the #set_content_id_alias_and_embed_code callback
      # run after validation in Edition::Documentable
      document.valid?
      document.content_id_alias = document.friendly_id
      document.embed_code = document.built_embed_code
    end
  end
end
