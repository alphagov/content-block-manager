FactoryBot.define do
  factory :organisation, class: "Organisation" do
    id { SecureRandom.uuid }
    sequence(:name) { |index| "organisation-#{index}" }
  end

  initialize_with do
    new(**attributes)
  end
end
