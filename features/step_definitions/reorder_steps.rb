And(/^I click on reorder$/) do
  click_on "Reorder"
end

And(/^I change the order of the contact methods$/) do
  find("a[data-testid='email_addresses.email-us-move-up-button']").click
end

And(/^I click to save the order/) do
  click_on "Save order"
end

And(/^the contact methods should be in the new order$/) do
  items = page.find_all(".content-block__contact-list--nested")

  assert_equal "Email us", items[0].find_all(".content-block__contact-key")[0].text
end

Then(/^I should see the contact methods in the new order$/) do
  Capybara.current_session.driver.with_playwright_page do |page|
    item = page.get_by_testid("reorder-item-0")
    expect(item).to playwright_matchers.have_text("Email us")
  end
end

Then("I should see {string} in the ordered items") do |item_title|
  Capybara.current_session.driver.with_playwright_page do |p_page|
    item = p_page.get_by_testid("reorder-item-3")
    expect(item).to playwright_matchers.have_text(item_title)
  end
end
