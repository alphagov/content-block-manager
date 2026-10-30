Then("I see the content block list page") do
  expect(page).to have_content("Content Block Manager (v2)")
  expect(page).to have_content("Content Block Manager (v2)")
end

Then("I am returned to the V2 index page") do
  expect(current_path).to eq(v2_documents_path)
end

Then("I click the View link for {string}") do |document_title|
  within(".govuk-summary-card__title-wrapper", text: document_title) do
    click_link "View"
  end
end

Then("I am taken to the Show page for {string}") do |document_title|
  should_see_title_of_document_contains(document_title)
end

Given("a {string} document in the {string} state exists") do |type, state|
  create_document_with_state(state:, type:)
end

And("that document has a previous published edition") do
  create_previous_published_edition
end

When("I visit that document") do
  visit v2_document_path(@document)
end

Then("I see the document metadata for the {string} {string} document") do |state, type|
  should_see_title_of_document_contains(type)
  should_see_status_of_document(state)
  should_see_block_type_of_document(type)
end

Then("I have the ability to create a new draft edition for the document [not currently functional]") do
  # Currently the button is displayed, but is not functional
  should_see_document_button("Edit #{@document.block_type.humanize.downcase}")
end

Then("I have the ability to edit the draft edition") do
  button_text = @edition.state == "draft" ? I18n.t("v2.document.show.buttons.finalised_in_draft") : I18n.t("v2.document.show.buttons.finalised_not_in_draft")
  should_see_document_button(button_text, href: edit_v2_document_edition_path(@document, @document.most_recent_edition))
end

And("I have the ability to view the current published edition") do
  should_see_document_link(I18n.t("v2.document.show.links.published_edition"))
end

And("I follow the link to create a new content block") do
  click_link("Create content block")
end

And("I visit the content block list page") do
  visit v2_documents_path
end

And("I select {string}") do |block_type|
  choose block_type
end

Then("I see the select content block type page") do
  within "h1" do
    expect(page).to have_content("Select a content block")
  end
end

Then("I see an error telling me to select a block type") do
  expect(page).to have_content("Select a content block")
end
