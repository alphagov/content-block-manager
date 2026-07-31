When("I am viewing the form to create a new Time Period Edition") do
  visit new_block_time_period_edition_path
end

When("I fill the Time Period Edition details correctly") do
  fill_in_edition_details(
    title: "Test Time Period Edition",
    description: "This is a test time period edition.",
    lead_organisation: "Ministry of Example",
    instructions: "Please review and publish.",
  )
end

When("I fill the Time Period Edition details incorrectly") do
  fill_in_edition_details(
    title: "",
    description: "This is a test time period edition.",
    lead_organisation: "",
    instructions: "Please review and publish.",
  )
end

Then("I see that the Edition was created successfully") do
  expect(page).to have_content(I18n.t("block/time_period_edition.create.success"))
end

Then("I see which Time Period Edition errors I need to correct") do
  expect(page).to have_content("Title cannot be blank")
  expect(page).to have_content("Lead organisation cannot be blank")
end

def fill_in_edition_details(title:, description:, lead_organisation:, instructions:)
  fill_in "edition[title]", with: title
  fill_in "Description", with: description
  select lead_organisation, from: "Lead organisation"
  fill_in "Instructions to publishers", with: instructions
end
