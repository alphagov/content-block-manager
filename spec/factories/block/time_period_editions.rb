FactoryBot.define do
  factory :time_period_edition, class: "Block::TimePeriodEdition" do
    association :document, factory: :block_document, block_type: "time_period"
    sequence(:title) { |n| "Time Period #{n}" }
    description { "A time period description" }
  end
end
