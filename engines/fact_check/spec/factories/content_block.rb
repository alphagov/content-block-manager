FactoryBot.define do
  factory :content_block, class: "ContentBlock" do
    edition { build(:edition, document:, id:) }

    transient do
      schema { build(:schema) }
      document { build(:document, schema:) }
      id { "123" }
    end

    initialize_with do
      new(edition)
    end
  end
end
