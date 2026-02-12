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

  def changed_details
    OpenStruct.new({
      "date_time" => {
        "start" => {
          "date" => "2026-05-07",
          "time" => "23:59",
        },
        "end" => {
          "date" => "2025-05-06",
          "time" => "00:00",
        },
      },
      "description" => "Changed description",
      "note" => "Changed note",
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

When("I edit the draft time period block") do
  visit workflow_path(edition, step: "review")
  click_link "Edit"

  time_period.fill_time_period_fields(details: time_period.changed_details, page: page)
  click_button "Save and continue"
end

Then("I should see the edited time period values have been saved") do
  expect(page).to have_content(time_period.changed_details.date_time)
end
