FactoryBot.define do
  factory :block_time_period_date_range, class: "Block::TimePeriodDateRange" do
    association :edition, factory: :time_period_edition
    start { Time.zone.parse("2025-04-06 00:00") }
    self.end { Time.zone.parse("2026-04-05 23:59") }
  end
end
