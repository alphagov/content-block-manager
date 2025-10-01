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

def pension_rate_embed_code
  @pension_rate_embed_code ||=
    Document.find_by!(block_type: "pension")
      .embed_code_for_field("rates/my-rate/amount")
end
