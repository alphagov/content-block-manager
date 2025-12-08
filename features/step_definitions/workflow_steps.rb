Given("the draft workflow has not been completed") do
  draft.update_column(:workflow_completed_at, nil)
end

Given("the draft workflow has been completed") do
  draft.update_column(:workflow_completed_at, 1.minute.ago)
end

Then("I see that I can complete the workflow with 'Send to 2i'") do
  expect(page).to have_css(
    "button[form='review']", text: "Send to 2i"
  )
end

def draft
  Edition.draft.last
end
