When(/^I click to move the first telephone number down$/) do
  Capybara.current_session.driver.with_playwright_page do |page|
    page.locator(".app-c-reorder-items__button[data-action='move-down']").first.dispatch_event("click")
  end
end

And(/^I click to move the last telephone number up$/) do
  Capybara.current_session.driver.with_playwright_page do |page|
    page.locator(".app-c-reorder-items__button[data-action='move-up']").last.dispatch_event("click")
  end
end

Then(/^the telephone numbers should show in the following order:$/) do |table|
  fieldsets = page.all("[data-ga4-section='Telephone number'] fieldset")
  field_prefix = "edition[details][#{@object_type.pluralize}][telephone_numbers][]"

  screenshot

  table.hashes.each_with_index do |row, index|
    row.each do |key, value|
      field = fieldsets[index].find(:css, "[name='#{field_prefix}[#{key}]']")
      expect(field.value).to eq(value)
    end
  end
end
