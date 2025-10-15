When("I click to copy the embed code for the pension rate") do
  within(".govuk-summary-list__row", text: "Amount") do
    click_copy_code_link
  end
end

When("I click to copy the embed code for the contact's default block") do
  within(".gem-c-summary-card", text: "Default block") do
    click_copy_code_link
  end
end

Then(/the ([^"]*) embed code should be copied to my clipboard/) do |code_type|
  Capybara.current_session.driver.with_playwright_page do |page|
    page.context.grant_permissions(%w[clipboard-read])
  end
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(embed_code_for(code_type))
end

Then(/the ([^"]*) embed code should be visible/) do |code_type|
  expect(page).to have_content(embed_code_for(code_type))
end

Then(/I should not see the ([^"]*) embed code displayed/) do |code_type|
  expect(page).to have_no_content(embed_code_for(code_type))
end

Then(/I should see the ([^"]*) embed code flash up for an interval/) do |code_type|
  Capybara.current_session.driver.with_playwright_page do |p_page|
    block = p_page.get_by_testid(test_block_id_for(code_type))
    expect(block).to playwright_matchers.have_text(embed_code_for(code_type))
    # a short interval of time passes
    expect(block).not_to playwright_matchers.have_text(embed_code_for(code_type))
  end
end

def click_copy_code_link
  find("a", text: "Copy code").click
  has_text?("Code copied")
end

def test_block_id_for(code_type)
  case code_type
  when "pension rate"
    "rates_listing"
  when "contact default block"
    "default_block"
  end
end

def embed_code_for(code_type)
  case code_type
  when "pension rate"
    pension_rate_embed_code
  when "contact default block"
    contact_default_block_embed_code
  end
end

def pension_rate_embed_code
  @pension_rate_embed_code ||=
    Document.find_by!(block_type: "pension")
      .embed_code_for_field("rates/my-rate/amount")
end

def contact_default_block_embed_code
  @contact_default_block_embed_code ||=
    Document.find_by!(block_type: "contact")
      .embed_code
end
