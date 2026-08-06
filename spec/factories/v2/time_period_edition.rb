FactoryBot.define do
  factory :v2_time_period_edition, class: "V2::TimePeriodEdition" do
    association :document, factory: :v2_document, block_type: "time_period"
    sequence(:title) { |n| "Time Period #{n}" }
    description { "A time period description" }
    lead_organisation_id { SecureRandom.uuid }
    creator { association :user }
  end
end
