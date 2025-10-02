When("I click to copy the embed code for the pension rate") do
  within(".govuk-summary-list__row", text: "Amount") do
    find("a", text: "Copy code").click
    has_text?("Code copied")
  end
end

Then("the embed code should be copied to my clipboard") do
  Capybara.current_session.driver.with_playwright_page do |page|
    page.context.grant_permissions(%w[clipboard-read])
  end
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(pension_rate_embed_code)
end

Then("the embed code for the pension rate should be visible") do
  expect(page).to have_content(pension_rate_embed_code)
end

Then("I should not see the embed code displayed for the pension rate") do
  expect(page).to have_no_content(pension_rate_embed_code)
end

Then("I should see the embed code flash up for an interval") do
  Capybara.current_session.driver.with_playwright_page do |p_page|
    block = p_page.get_by_testid("rates_listing")
    expect(block).to playwright_matchers.have_text(pension_rate_embed_code)
    # a short interval of time passes
    expect(block).not_to playwright_matchers.have_text(pension_rate_embed_code)
  end
end

def pension_rate_embed_code
  @pension_rate_embed_code ||=
    Document.find_by!(block_type: "pension")
      .embed_code_for_field("rates/my-rate/amount")
end
