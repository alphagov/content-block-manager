Then("I see the content block list page") do
  expect(page).to have_content("Content Block Manager (v2)")
  expect(page).to have_content("Content Block Manager (v2)")
end

When("I visit the document with ID {int}") do |int|
  visit v2_document_path(int)
end
