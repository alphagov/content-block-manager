FactoryBot.define do
  factory :v2_domain_event, class: "V2::DomainEvent" do
    document { nil }
    user { build(:user) }
    name { nil }
    metadata { {} }
    edition { nil }
    version { nil }
  end
end
