And(/^I click to share the fact check link$/) do
  find("span", text: "Share factcheck link").click
end

Then(/^I should see a link to share the block for factcheck$/) do
  extend FactCheckHelper
  @fact_check_url = fact_check_url_with_token(@content_block)
  expect(page).to have_selector("input[value='#{@fact_check_url}']")
end

When(/^I click to copy the link$/) do
  click_on "Copy link"
end

Then(/^the link should be copied to my clipboard$/) do
  extend FactCheckHelper

  Capybara.current_session.driver.with_playwright_page do |page|
    page.context.grant_permissions(%w[clipboard-read])
  end
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(@fact_check_url)
end
