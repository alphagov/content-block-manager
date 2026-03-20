FactoryBot.define do
  factory :domain_event, class: "DomainEvent" do
    document { nil }
    user { build(:user) }
    name { nil }
    metadata { {} }
    edition { nil }
    version { nil }
  end
end
