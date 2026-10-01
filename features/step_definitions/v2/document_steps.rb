Then("I see the content block list page") do
  expect(page).to have_content("Content Block Manager (v2)")
  expect(page).to have_content("Content Block Manager (v2)")
end

When("I visit the document with ID {int}") do |int|
  visit v2_document_path(int)
end

When("I visit a {string} {string} document") do |state, type|
  edition_type = "v2_#{type}_edition".parameterize.underscore.to_sym
  @time_period_edition = FactoryBot.create(edition_type)

  visit v2_document_path(@time_period_edition.document, state: state.parameterize.underscore)
end

Then("I should see that the document state is {string}") do |expected_state|
  expect(page).to have_css(".govuk-tag", text: expected_state)
end

Then("I should see the block type is {string}") do |expected_type|
  expect(page).to have_css(".govuk-caption-xl", text: expected_type)
end
