Given("I am viewing the grouped contact methods") do
  visit workflow_path(edition, step: :group_contact_methods)
end

Given("the draft workflow has not been completed") do
  draft.update_column(:state, :draft)
end

Given("the draft workflow has been completed") do
  draft.update_column(:state, "draft_complete")
end

Then("I should be returned to the view of grouped contact methods") do
  expect(current_path).to eq(workflow_path(edition, step: :group_contact_methods))
end

Then("I see that I can complete the workflow with 'Ready for 2i'") do
  expect(page).to have_css(
    "button[form='review']", text: "Ready for 2i"
  )
end

Then("I should see a notice that the completed drafted has been saved") do
  within(".govuk-notification-banner--success") do
    expect(page).to have_content(Edition::StateTransitionMessage.new(state: :draft_complete).to_s)
  end
end

When("I complete the initial step of the workflow") do
  # initial step
  expect(current_path).to eq(workflow_path(edition, step: :edit_draft))
  click_button "Save and continue"
end

Then("I should be able to complete all the steps in the workflow for a further edition") do
  # initial step
  expect(current_path).to eq(workflow_path(edition, step: :edit_draft))
  click_button "Save and continue"

  # links step
  expect(current_path).to eq(workflow_path(edition, step: :review_links))
  click_button "Save and continue"

  # internal-note step
  expect(current_path).to eq(workflow_path(edition, step: :internal_note))
  click_button "Save and continue"

  # change-note step
  expect(current_path).to eq(workflow_path(edition, step: :change_note))
  choose "No - it's a minor edit that does not change the meaning"
  click_button "Save and continue"

  # scheduling step
  expect(current_path).to eq(workflow_path(edition, step: :schedule_publishing))
  choose "Publish the edit now"
  click_button "Save and continue"

  # workflow review step
  expect(current_path).to eq(workflow_path(edition, step: :review))
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
