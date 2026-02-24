module TimePeriodHelpers
  require "rspec/rails"
  include RSpec::Matchers

  def initial_details
    OpenStruct.new({
      "date_range" => {
        "start" => {
          "date" => "2025-04-06",
          "time" => "00:00",
        },
        "end" => {
          "date" => "2026-04-05",
          "time" => "23:59",
        },
      },
      "description" => "Initial description",
      "note" => "Initial note",
    })
  end

  def changed_details
    OpenStruct.new({
      "date_range" => {
        "start" => {
          "date" => "2026-05-07",
          "time" => "23:59",
        },
        "end" => {
          "date" => "2027-05-06",
          "time" => "00:00",
        },
      },
      "description" => "Changed description",
      "note" => "Changed note",
    })
  end

  def fill_time_period_fields(details:, page:)
    page.fill_in(
      "edition_details_date_range_start_date",
      with: details.date_range.dig("start", "date"),
    )
    page.fill_in(
      "edition_details_date_range_start_time",
      with: details.date_range.dig("start", "time"),
    )

    page.fill_in(
      "edition_details_date_range_end_date",
      with: details.date_range.dig("end", "date"),
    )
    page.fill_in(
      "edition_details_date_range_end_time",
      with: details.date_range.dig("end", "time"),
    )
  end

  def should_see_time_period_values_in_form(details:, page:)
    expect(page).to have_field(
      "edition_details_date_range_start_date",
      with: details.date_range.dig("start", "date"),
    )
    expect(page).to have_field(
      "edition_details_date_range_start_time",
      with: details.date_range.dig("start", "time"),
    )

    expect(page).to have_field(
      "edition_details_date_range_end_date",
      with: details.date_range.dig("end", "date"),
    )
    expect(page).to have_field(
      "edition_details_date_range_end_time",
      with: details.date_range.dig("end", "time"),
    )
  end

  def should_see_time_period_represented_clearly(details:, page:)
    page.within("div[title='Start']") do
      expect(page).to have_content("Date")
      expect(page).to have_content(details.date_range.dig("start", "date"))

      expect(page).to have_content("Time")
      expect(page).to have_content(details.date_range.dig("start", "time"))
    end

    page.within("div[title='End']") do
      expect(page).to have_content("Date")
      expect(page).to have_content(details.date_range.dig("end", "date"))

      expect(page).to have_content("Time")
      expect(page).to have_content(details.date_range.dig("end", "time"))
    end
  end
end

World(time_period: TimePeriodHelpers)

When("I proceed to add a date range for the Time period") do
  click_button("Save and continue")

  expect(current_path).to eq(new_sole_embedded_object_edition_path(edition, :date_range))
end

When("I supply the initial time periods correctly") do
  time_period.fill_time_period_fields(details: time_period.initial_details, page: page)
end

When("I supply the changed values of the time period") do
  click_button("Save and continue")

  expect(current_path).to eq(edit_sole_embedded_object_edition_path(edition, :date_range))
  time_period.fill_time_period_fields(details: time_period.changed_details, page: page)
end

When("I edit the draft time period block") do
  click_link("Complete draft")

  expect(current_path).to eq(workflow_path(edition, step: :edit_draft))
  click_button "Save and continue"

  expect(current_path).to eq(edit_sole_embedded_object_edition_path(@edition, :date_range))
  time_period.should_see_time_period_values_in_form(details: time_period.initial_details, page: page)

  time_period.fill_time_period_fields(details: time_period.changed_details, page: page)
  click_button "Save and continue"
end

Then("I should see the edited time period values have been saved") do
  time_period.should_see_time_period_represented_clearly(details: time_period.changed_details, page: page)
end

Then("I should see the changed values of the new edition") do
  time_period.should_see_time_period_represented_clearly(details: time_period.changed_details, page: page)
end

Then("I see the initial time period represented clearly") do
  time_period.should_see_time_period_represented_clearly(details: time_period.initial_details, page: page)
end
