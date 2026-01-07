Given("I am viewing the grouped contact methods") do
  visit workflow_path(edition, step: :group_contact_methods)
end

Given("the draft workflow has not been completed") do
  draft.update_column(:workflow_completed_at, nil)
end

Given("the draft workflow has been completed") do
  draft.update_column(:workflow_completed_at, 1.minute.ago)
end

When("I choose to add a contact link") do
  choose("Contact link")
  click_button("Save and continue")
end

Then("I should be returned to the view of grouped contact methods") do
  expect(current_path).to eq(workflow_path(edition, step: :group_contact_methods))
end

Then("I see that I can complete the workflow with 'Send to 2i'") do
  expect(page).to have_css(
    "button[form='review']", text: "Send to 2i"
  )
end

Then("I should see a notice that the completed drafted has been saved") do
  within(".govuk-notification-banner--success") do
    expect(page).to have_content(I18n.t("edition.confirmation_page.drafted.banner"))
  end
end

def draft
  Edition.draft.last
end

Then("the {string} field should be checked") do |field|
  expect(find("##{field}-0")["checked"]).to be_truthy
end

Then("the {string} field should be set to {string}") do |field, value|
  expect(find("##{field}")["value"]).to eq(value)
end
