Then("I should be offered the preview facility without mention of reordering") do
  expect(current_path).to eq(workflow_path(Edition.last, step: :group_contact_methods))
  expect(page).to have_link("Preview", href: preview_edition_path(Edition.last))
  within "a[title='Preview block']" do
    expect(page).not_to have_content("Preview and reorder")
  end
end

And(/^I click on reorder$/) do
  click_on "Reorder"
end

Then("I should be on the reordering form") do
  expect(current_path).to eq(order_edit_edition_path(Edition.last))
end

And(/^I change the order of the contact methods$/) do
  find("a[data-testid='email_addresses.email-the-team-move-up-button']").click
end

And(/^I click to save the order/) do
  click_on "Save order"
end

And(/^the contact methods should be in the new order$/) do
  items = page.find_all(".content-block dl")

  assert_equal "Email The Team", items[0].find_all("dt")[0].text
end

Then(/^I should see the contact methods in the new order$/) do
  Capybara.current_session.driver.with_playwright_page do |page|
    item = page.get_by_testid("reorder-item-0")
    expect(item).to playwright_matchers.have_text("Email The Team")
  end
end

Then("I should see {string} in the ordered items") do |item_title|
  Capybara.current_session.driver.with_playwright_page do |p_page|
    item = p_page.get_by_testid("reorder-item-3")
    expect(item).to playwright_matchers.have_text(item_title)
  end
end
