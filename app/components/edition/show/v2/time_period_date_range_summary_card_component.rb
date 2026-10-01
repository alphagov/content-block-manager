class Edition::Show::V2::TimePeriodDateRangeSummaryCardComponent < ViewComponent::Base
  attr_reader :summary_card_actions

  def initialize(date_range:, summary_card_actions: nil)
    @date_range = date_range
    @summary_card_actions = summary_card_actions
  end

  def title
    "Date range details"
  end

  def rows
    [
      { key: "Start", value: @date_range.start.strftime("%-d %B %Y") },
      { key: "End", value: @date_range.end.strftime("%-d %B %Y") },
    ]
  end
end
