class Edition::Show::V2::TimePeriodDateRangeSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def title
    "Date range details"
  end

  def rows
    [
      { key: "Start", value: @edition.date_range.start.strftime("%-d %B %Y") },
      { key: "End", value: @edition.date_range.end.strftime("%-d %B %Y") },
    ]
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: edit_v2_time_period_edition_time_period_date_range_path(@edition),
      },
    ]
  end
end
