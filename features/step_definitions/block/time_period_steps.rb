Given("I am on the new-style time period form") do
  visit new_block_time_period_edition_path
end

When("I fill the new-style time period form correctly") do
  fill_in "Title", with: "Current Tax Year"
  fill_in "Description", with: "A time period representing the current tax year"
  select "Ministry of Example", from: "edition_lead_organisation_id"
  fill_in "Instructions to publishers", with: "Use this for current tax year content"
end

When("I submit the new-style time period form incorrectly") do
  # no-op
  click_button "Save and continue"
end

Then("I see the errors messages describing the problems with the new-style edition") do
  expect(page).to have_content("Title cannot be blank")
  expect(page).to have_content("Lead organisation cannot be blank")
end

When("I proceed to add a date range for the new-style Time period") do
  click_button "Save and continue"
  @edition = Block::TimePeriodEdition.last
end

When("I supply the initial new-style time periods correctly") do
  # Start date
  fill_in "edition[date_range_attributes][start(3i)]", with: "6"
  fill_in "edition[date_range_attributes][start(2i)]", with: "4"
  fill_in "edition[date_range_attributes][start(1i)]", with: "2025"
  select "09", from: "start_hour"
  select "00", from: "start_minute"

  # End date
  fill_in "edition[date_range_attributes][end(3i)]", with: "5"
  fill_in "edition[date_range_attributes][end(2i)]", with: "4"
  fill_in "edition[date_range_attributes][end(1i)]", with: "2026"
  select "17", from: "end_hour"
  select "30", from: "end_minute"
end

Then("I see the initial new-style time period represented clearly") do
  edition = @edition.reload

  expect(page).to have_content(edition.title)
  expect(page).to have_content(edition.description)
  expect(page).to have_content(edition.instructions_to_publishers)
  expect(page).to have_content(edition.document.embed_code)

  expect(page).to have_content(
    ContentBlockTools::Presenters::FieldPresenters::TimePeriod::DatePresenter.new(
      edition.date_range.start.to_s,
    ).render,
  )
  expect(page).to have_content(
    ContentBlockTools::Presenters::FieldPresenters::TimePeriod::DatePresenter.new(
      edition.date_range.end.to_s,
    ).render,
  )
end
