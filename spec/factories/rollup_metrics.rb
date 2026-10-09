FactoryBot.define do
  factory :rollup_metric, class: "RollupMetric" do
    document
    views { 0 }
    locations { 0 }
    instances { 0 }
    organisations { 0 }
    lead_organisation_name { nil }
    refreshed_at { Time.current }
  end
end
