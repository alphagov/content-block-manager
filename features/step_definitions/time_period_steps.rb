module TimePeriodHelpers
  require "rspec/rails"
  include RSpec::Matchers

  def initial_details
    OpenStruct.new({
      "date_range" => {
        "start" => "2025-04-06T00:00:00+01:00",
        "end" => "2026-04-05T23:59:00+01:00",
      },
      "description" => "Initial description",
    })
  end

  def incorrect_details
    OpenStruct.new({
      "date_range" => {
        "start" => "2025-04-05T00:00:00+01:00",
        "end" => "2025-04-04T23:59:00+01:00",
      },
      "description" => "Initial description",
    })
  end

  def changed_details
    OpenStruct.new({
      "date_range" => {
        "start" => "2026-05-07T23:59:00+01:00",
        "end" => "2027-05-06T00:00:00+01:00",
      },
      "description" => "Changed description",
    })
  end

  # Raw form values for an invalid date (30 Feb doesn't exist)
  def invalid_date_raw_values
    {
      "start" => { "day" => "30", "month" => "02", "year" => "2025", "hour" => "00", "minute" => "00" },
      "end" => { "day" => "05", "month" => "04", "year" => "2026", "hour" => "23", "minute" => "59" },
    }
  end

  def fill_time_period_fields_raw(raw_values:, page:)
    page.fill_in("start_day", with: raw_values["start"]["day"])
    page.fill_in("start_month", with: raw_values["start"]["month"])
    page.fill_in("start_year", with: raw_values["start"]["year"])
    page.select(raw_values["start"]["hour"], from: "start_hour")
    page.select(raw_values["start"]["minute"], from: "start_minute")

    page.fill_in("end_day", with: raw_values["end"]["day"])
    page.fill_in("end_month", with: raw_values["end"]["month"])
    page.fill_in("end_year", with: raw_values["end"]["year"])
    page.select(raw_values["end"]["hour"], from: "end_hour")
    page.select(raw_values["end"]["minute"], from: "end_minute")
  end

  def should_see_raw_time_period_values_in_form(raw_values:, page:)
    expect(page).to have_field("start_day", with: raw_values["start"]["day"])
    expect(page).to have_field("start_month", with: raw_values["start"]["month"])
    expect(page).to have_field("start_year", with: raw_values["start"]["year"])
    expect(page).to have_field("start_hour", with: raw_values["start"]["hour"])
    expect(page).to have_field("start_minute", with: raw_values["start"]["minute"])

    expect(page).to have_field("end_day", with: raw_values["end"]["day"])
    expect(page).to have_field("end_month", with: raw_values["end"]["month"])
    expect(page).to have_field("end_year", with: raw_values["end"]["year"])
    expect(page).to have_field("end_hour", with: raw_values["end"]["hour"])
    expect(page).to have_field("end_minute", with: raw_values["end"]["minute"])
  end

  def fill_time_period_fields(details:, page:)
    start_time = Time.iso8601(details.date_range["start"])
    page.fill_in("start_day", with: start_time.day.to_s.rjust(2, "0"))
    page.fill_in("start_month", with: start_time.month.to_s.rjust(2, "0"))
    page.fill_in("start_year", with: start_time.year)
    page.select(start_time.strftime("%H"), from: "start_hour")
    page.select(start_time.strftime("%M"), from: "start_minute")

    end_time = Time.iso8601(details.date_range["end"])
    page.fill_in("end_day", with: end_time.day.to_s.rjust(2, "0"))
    page.fill_in("end_month", with: end_time.month.to_s.rjust(2, "0"))
    page.fill_in("end_year", with: end_time.year)
    page.select(end_time.strftime("%H"), from: "end_hour")
    page.select(end_time.strftime("%M"), from: "end_minute")
  end

  def should_see_time_period_values_in_form(details:, page:, padded: false)
    start_time = Time.iso8601(details.date_range["start"])
    expect(page).to have_field("start_day", with: format_day_or_month(start_time.day, padded:))
    expect(page).to have_field("start_month", with: format_day_or_month(start_time.month, padded:))
    expect(page).to have_field("start_year", with: start_time.year)
    expect(page).to have_field("start_hour", with: start_time.strftime("%H"))
    expect(page).to have_field("start_minute", with: start_time.strftime("%M"))

    end_time = Time.iso8601(details.date_range["end"])
    expect(page).to have_field("end_day", with: format_day_or_month(end_time.day, padded:))
    expect(page).to have_field("end_month", with: format_day_or_month(end_time.month, padded:))
    expect(page).to have_field("end_year", with: end_time.year)
    expect(page).to have_field("end_hour", with: end_time.strftime("%H"))
    expect(page).to have_field("end_minute", with: end_time.strftime("%M"))
  end

  def format_day_or_month(value, padded:)
    padded ? value.to_s.rjust(2, "0") : value
  end

  def should_see_time_period_represented_clearly(details:, page:)
    start_iso = details.date_range["start"]
    end_iso = details.date_range["end"]

    expected_start_date = ContentBlockTools::Presenters::FieldPresenters::TimePeriod::DatePresenter.new(start_iso).render
    expected_end_date = ContentBlockTools::Presenters::FieldPresenters::TimePeriod::DatePresenter.new(end_iso).render

    expect(page).to have_content("Start")
    expect(page).to have_content(expected_start_date)

    expect(page).to have_content("End")
    expect(page).to have_content(expected_end_date)
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
  find("span[data-ga4-expandable='']", text: "All date range attributes").click
  time_period.should_see_time_period_represented_clearly(details: time_period.changed_details, page: page)
end

Then("I see the initial time period represented clearly") do
  time_period.should_see_time_period_represented_clearly(details: time_period.initial_details, page: page)
end

Then("I should see the description of the time period block") do
  expect(page).to have_content(time_period.initial_details.description)
end

Then("the time period's date range block should not be shown") do
  expect(page).to have_no_css(".app-c-embedded-objects-blocks-component", text: "Date range")
end

Then("I should see an error message telling me that the end date cannot be before the start date") do
  expect(page).to have_selector(
    "a[href='#edition_details_date_range_end']",
    text: I18n.t("activerecord.errors.models.edition.minimum",
                 attribute: "End",
                 minimum_date: "Start"),
  )
end

Then("the time period date range fields should be populated with the values submitted") do
  time_period.should_see_time_period_values_in_form(details: time_period.incorrect_details, page: page, padded: true)
end

Then("I see embed codes for the time period date and time values") do
  within ".subschema-listing[data-testid='date_range_listing']" do
    %w[
      date_range/start
      date_range/end
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

When("I edit the draft time period entering the invalid value of 30 Feb") do
  click_link("Complete draft")

  expect(current_path).to eq(workflow_path(edition, step: :edit_draft))
  click_button "Save and continue"

  expect(current_path).to eq(edit_sole_embedded_object_edition_path(@edition, :date_range))
  time_period.fill_time_period_fields_raw(raw_values: time_period.invalid_date_raw_values, page: page)
  click_button "Save and continue"
end

Then("I should see an error message telling me that the date range field is invalid") do
  expect(page).to have_content("Start is invalid")
end

Then("the time period date range fields should be populated with the invalid values submitted") do
  time_period.should_see_raw_time_period_values_in_form(raw_values: time_period.invalid_date_raw_values, page: page)
end
