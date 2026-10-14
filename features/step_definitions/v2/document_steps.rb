Then("I see the content block list page") do
  expect(page).to have_content("Content Block Manager (v2)")
  expect(page).to have_content("Content Block Manager (v2)")
end

When("I visit a {string} {string} document") do |state, type|
  edition_type = "v2_#{type}_edition".parameterize.underscore.to_sym
  @edition = FactoryBot.create(edition_type)

  visit v2_document_path(@edition.document, state: state.parameterize.underscore)
end

Then("I am returned to the V2 index page") do
  expect(current_path).to eq(v2_documents_path)
end

Then("I click the View link for {string}") do |document_title|
  within(".govuk-summary-card__title-wrapper", text: document_title) do
    click_link "View"
  end
end

Then("I should see the correct page elements for a published {string} document") do |type|
  should_see_title_of_document_contains(type)
  should_see_status_of_document("Published")
  should_see_block_type_of_document(type)
  should_see_document_buttons(["Edit #{type.downcase}"])
end

Then("I should see the correct page elements for a draft {string} document") do |type|
  should_see_title_of_document_contains(type)
  should_see_status_of_document("Draft")
  should_see_block_type_of_document(type)
  should_see_document_buttons([I18n.t("v2.document.show.buttons.finalised_in_draft")])
  should_see_document_links([I18n.t("v2.document.show.links.published_edition")])
end

Then("I should see the correct page elements for a scheduled {string} document") do |type|
  should_see_title_of_document_contains(type)
  should_see_status_of_document("Scheduled")
  should_see_block_type_of_document(type)
  should_see_document_buttons([I18n.t("v2.document.show.buttons.finalised_not_in_draft")])
  should_see_document_links([I18n.t("v2.document.show.links.published_edition")])
end

Then("I am taken to the Show page for {string}") do |document_title|
  should_see_title_of_document_contains(document_title)
end
