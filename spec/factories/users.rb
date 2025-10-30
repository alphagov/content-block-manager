FactoryBot.define do
  sequence :name do |n|
    "user-#{n}"
  end

  sequence :email do |n|
    "user-#{n}@example.com"
  end

  sequence :uid do |n|
    "uid-#{n}"
  end

  factory :user do
    name
    email
    uid
    permissions { [User::Permissions::SIGNIN] }
  end

  factory :scheduled_publishing_robot, parent: :user do
    uid { nil }
    name { "Scheduled Publishing Robot" }
    permissions { [User::Permissions::SIGNIN] }
  end
end
