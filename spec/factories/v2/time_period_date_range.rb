FactoryBot.define do
  factory :v2_time_period_date_range, class: "V2::TimePeriodDateRange" do
    association :edition, factory: :v2_time_period_edition
    start { Time.zone.parse("2025-04-06 00:00") }
    self.end { Time.zone.parse("2026-04-05 23:59") }
  end
end
