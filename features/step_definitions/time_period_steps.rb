module TimePeriodHelpers
  def initial_details
    OpenStruct.new({
      "date_time" => {
        "start" => {
          "date" => "2025-04-06",
          "time" => "00:00",
        },
        "end" => {
          "date" => "2025-04-05",
          "time" => "23:59",
        },
      },
      "description" => "Initial description",
      "note" => "Initial note",
    })
  end

  def fill_time_period_fields(details:, page:)
    page.fill_in(
      "edition_details_date_time_start_date",
      with: details.date_time.dig("start", "date"),
    )
    page.fill_in(
      "edition_details_date_time_start_time",
      with: details.date_time.dig("start", "time"),
    )

    page.fill_in(
      "edition_details_date_time_end_date",
      with: details.date_time.dig("end", "date"),
    )
    page.fill_in(
      "edition_details_date_time_end_time",
      with: details.date_time.dig("end", "time"),
    )
  end
end

World(time_period: TimePeriodHelpers)

When("I supply the time periods correctly") do
  time_period.fill_time_period_fields(details: time_period.initial_details, page: page)
end
