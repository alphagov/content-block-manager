FactoryBot.define do
  factory :content_block, class: "ContentBlock" do
    edition { build(:edition, document:) }

    transient do
      schema { build(:schema) }
      document { build(:document, schema:) }
    end

    initialize_with do
      new(edition)
    end
  end
end
