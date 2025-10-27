When("I add a filter for blocks updated two days ago") do
  date = 2.days.before(Time.zone.now)

  fill_in "last_updated_from_1i", with: date.year
  fill_in "last_updated_from_2i", with: date.month
  fill_in "last_updated_from_3i", with: date.day

  fill_in "last_updated_to_1i", with: date.year
  fill_in "last_updated_to_2i", with: date.month
  fill_in "last_updated_to_3i", with: date.day
end

When("I input invalid dates to filter by") do
  fill_in "last_updated_from_1i", with: "1"
  fill_in "last_updated_from_2i", with: "34"
  fill_in "last_updated_from_3i", with: "56"

  fill_in "last_updated_to_1i", with: "1"
  fill_in "last_updated_to_2i", with: "67"
  fill_in "last_updated_to_3i", with: "56"
end

Then("'all organisations' is already selected as a filter") do
  expect(page).to have_field("Lead organisation", with: "")
end

When("I enter the keyword {string}") do |keyword|
  fill_in "Keyword", with: keyword
end

Then("I check the block type {string}") do |checkbox_name|
  check checkbox_name
end

Then("I select the lead organisation {string}") do |organisation|
  select organisation, from: "lead_organisation"
end

Then(/"(\d)" content blocks? .+ returned in total/) do |count|
  assert_text "#{count} #{'result'.pluralize(count.to_i)}"
end

When("I click to view results") do
  click_button "View results"
end
