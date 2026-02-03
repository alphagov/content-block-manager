When("I follow the link to complete the draft") do
  click_link("Complete draft")
end

Then("I see a principal call to action of 'Ready for 2i'") do
  within("form[action='#{edition_status_transitions_path(Edition.last)}']") do
    expect(page).to have_button("Ready for 2i")
  end
end

Then("I do not see a call to action of 'Ready for 2i'") do
  expect(page).to have_no_button("Ready for 2i")
end

Then("I see a secondary call to action edit the existing draft") do
  expect(page).to have_css(
    "a.govuk-button--secondary[href='#{workflow_path(edition, step: :edit_draft)}']",
    text: "Edit pension",
  )
end

Then("I see a important notice that I should share the review link") do
  within ".gem-c-notice" do
    expect(page).to have_content(I18n.t("edition.states.important_notice.awaiting_review"))
  end
end

Given("the document has been put into the awaiting_review state by another process") do
  # imagine it's a race condition...
  edition.update_column(:state, :awaiting_review)
end

When("I opt to send the edition to Review") do
  click_button "Ready for 2i"
end

Given("I try to send the draft to review without confirming that I have checked the contents") do
  uncheck "has_checked_content"
  click_button "Ready for 2i"
end

def complete_note_step
  expect(page).to have_content("Create internal note")
  click_button("Save and continue")
end

def complete_change_note_step
  expect(page).to have_content("Do users have to know the content has changed?")
  choose("No - it's a minor edit that does not change the meaning")
  click_button("Save and continue")
end

def complete_scheduling_step
  expect(page).to have_content("Select publish date")
  choose("Publish the edit now")
  click_button("Save and continue")
end

def edition
  @edition ||= Edition.last
end
