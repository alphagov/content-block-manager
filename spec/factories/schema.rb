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

    factory :embedded_schema, class: "Schema::EmbeddedSchema" do
      parent_schema { build(:schema) }
      config { {} }
      is_array { nil }

      initialize_with do
        new(block_type, body, parent_schema, config, is_array: is_array)
      end
    end
  end
end
