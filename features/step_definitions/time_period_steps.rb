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

  def incorrect_details
    OpenStruct.new({
      "date_range" => {
        "start" => {
          "date" => "2025-04-05",
          "time" => "00:00",
        },
        "end" => {
          "date" => "2025-04-04",
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
    start_year, start_month, start_day = details.date_range.dig("start", "date").split("-")
    start_hour, start_minute = details.date_range.dig("start", "time").split(":")

    page.fill_in("start_day", with: start_day)
    page.fill_in("start_month", with: start_month)
    page.fill_in("start_year", with: start_year)

    page.select(start_hour, from: "start_hour")
    page.select(start_minute, from: "start_minute")

    end_year, end_month, end_day = details.date_range.dig("end", "date").split("-")
    end_hour, end_minute = details.date_range.dig("end", "time").split(":")

    page.fill_in("end_day", with: end_day)
    page.fill_in("end_month", with: end_month)
    page.fill_in("end_year", with: end_year)

    page.select(end_hour, from: "end_hour")
    page.select(end_minute, from: "end_minute")
  end

  def should_see_time_period_values_in_form(details:, page:)
    start_year, start_month, start_day = details.date_range.dig("start", "date").split("-")
    start_hour, start_minute = details.date_range.dig("start", "time").split(":")

    expect(page).to have_field("start_day", with: start_day.to_i)
    expect(page).to have_field("start_month", with: start_month.to_i)
    expect(page).to have_field("start_year", with: start_year.to_i)

    expect(page).to have_field("start_hour", with: start_hour)
    expect(page).to have_field("start_minute", with: start_minute)

    end_year, end_month, end_day = details.date_range.dig("end", "date").split("-")
    end_hour, end_minute = details.date_range.dig("end", "time").split(":")

    expect(page).to have_field("end_day", with: end_day.to_i)
    expect(page).to have_field("end_month", with: end_month.to_i)
    expect(page).to have_field("end_year", with: end_year.to_i)

    expect(page).to have_field("end_hour", with: end_hour)
    expect(page).to have_field("end_minute", with: end_minute)
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

When("I supply the time periods with the end date before the start date") do
  time_period.fill_time_period_fields(details: time_period.incorrect_details, page: page)
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

Then("I should see an error message telling me that the end date cannot be before the start date") do
  expect(page).to have_selector("a[href='#edition_details_date_range_end_date']"),
                  text: I18n.t("activerecord.errors.models.edition.minimum",
                               attribute: "Date",
                               minimum_date: "Start date")
end

Then("I see embed codes for the time period date and time values") do
  within ".subschema-listing[data-testid='date_range_listing']" do
    %w[
      date_range/start/date
      date_range/start/time
      date_range/end/date
      date_range/end/time
    ].each do |embed_code|
      aggregate_failures do
        expect(page).to have_content(
          edition.document.embed_code_for_field(embed_code),
        )
      end
    end
  end
end

Then("I see embed code for the default time period block") do
  within ".gem-c-summary-card[title='Default block']" do
    expect(page).to have_content(
      edition.document.embed_code,
    )
  end
end
