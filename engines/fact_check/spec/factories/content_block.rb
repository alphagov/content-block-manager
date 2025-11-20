FactoryBot.define do
  factory :content_block do
    title { "Test title" }
    block_type { "test" }

    initialize_with do
      double("ContentBlock", **attributes)
    end
  end
end
