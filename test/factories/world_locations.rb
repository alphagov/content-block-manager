FactoryBot.define do
  factory :world_location, class: "WorldLocation" do
    sequence(:name) { |index| "world-location-#{index}" }
  end

  initialize_with do
    new(**attributes)
  end
end
