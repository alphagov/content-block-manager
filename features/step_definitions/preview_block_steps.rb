When(/^I click on Preview and reorder$/) do
  preview_block_button.click
end

Then("I should not see a preview button") do
  expect(page).to_not have_selector("a[title='Preview block']", text: "Preview and reorder")
end

Then(/^I should see a preview of my contact$/) do
  expect(page).to have_selector(".app-views-editions-preview")
end

When(/^I click to close the preview$/) do
  click_on "Close preview"
end

Then(/^I should see the add contact methods screen$/) do
  within ".govuk-summary-card" do
    @details["title"]
  end
end

def preview_block_button
  find("a[title='Preview block']", text: "Preview and reorder")
end

Then(/^I should see the review contact screen$/) do
  assert_text "I confirm that the details I’ve put into the content block have been checked and are factually correct."
end
