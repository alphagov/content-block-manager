FactoryBot.define do
  factory :edition, class: "Edition" do
    details { {} }
    created_at { Time.zone.now.utc }
    updated_at { Time.zone.now.utc }
    schema { build(:schema) }
    creator { build(:user) }

    lead_organisation_id { SecureRandom.uuid }

    document_id { nil }

    scheduled_publication { nil }

    instructions_to_publishers { nil }

    title { "Factory Title for Edition" }

    internal_change_note { "Something changed" }

    change_note { "Something changed publicly" }

    major_change { true }

    auth_bypass_id { SecureRandom.uuid }

    Schema.valid_schemas.each do |type|
      trait type.to_sym do
        after(:build) do |edition, _evaluator|
          unless edition.document_id || edition.document
            edition.document = build(:document, block_type: type)
          end
        end
      end
    end

    trait :draft do
      state { :draft }
    end

    trait :published do
      state { :published }
    end

    trait :scheduled do
      state { :scheduled }
      scheduled_publication { Time.zone.now.utc }
    end

    trait :superseded do
      state { :superseded }
    end

    trait :deleted do
      state { :deleted }
    end

    trait :awaiting_review do
      state { :awaiting_review }
    end

    trait :awaiting_factcheck do
      state { :awaiting_factcheck }
    end
  end
end
