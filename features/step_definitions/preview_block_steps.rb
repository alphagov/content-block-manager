When(/^I click on Preview$/) do
  click_on "Preview"
end

Then(/^I should see a preview of my contact$/) do
  within ".app-views-editions-preview" do
    assert_text @title
  end
end

When(/^I click to close the preview$/) do
  click_on "Close preview"
end

Then(/^I should see the add contact methods screen$/) do
  within ".govuk-summary-card" do
    @details["title"]
  end
end
