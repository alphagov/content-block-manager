FactoryBot.define do
  factory :content_block do
    title { "Test title" }
    block_type { "test" }
    auth_bypass_id { SecureRandom.uuid }

    initialize_with do
      double("ContentBlock", **attributes)
    end
  end
end
