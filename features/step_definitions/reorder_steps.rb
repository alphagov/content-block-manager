And(/^I click on reorder$/) do
  click_on "Reorder"
end

And(/^I click to move the contact form to the top$/) do
  find("a[data-testid='contact_links.contact-form-move-up-button']").click
end

And(/^I click to save the order/) do
  click_on "Save order"
end

And(/^the contact form should be at the top$/) do
  items = page.find_all(".content-block__contact-list--nested")

  assert_equal "Contact Form", items[0].find_all(".content-block__contact-key")[0].text
end

Then(/^I should see the contact form moved to the top$/) do
  Capybara.current_session.driver.with_playwright_page do |page|
    item = page.get_by_testid("reorder-item-0")
    expect(item).to playwright_matchers.have_text("Contact Form")
  end
end
