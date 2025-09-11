FactoryBot.define do
  factory :schema, class: "Schema" do
    body { {} }
    block_type { "block_type" }

    Schema.valid_schemas.each do |type|
      trait type.to_sym do
        block_type { type }
      end
    end

    initialize_with do
      new("#{Schema::SCHEMA_PREFIX}_#{block_type}", body)
    end
  end
end
