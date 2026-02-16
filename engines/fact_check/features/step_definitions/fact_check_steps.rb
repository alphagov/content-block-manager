When("I visit the fact check path for the block") do
  visit FactCheck::Engine.routes.url_helpers.block_path(@content_block.document.content_id_alias)
end

Then("I should see the block's title") do
  expect(page).to have_css("h1", text: @content_block.document.title)
end

Then("I should see {string} as a previous value") do |value|
  expect_removed_content_in_block(value)
end

Then("I should see {string} as a new value") do |value|
  expect_added_content_in_block(value)
end

Then("I should not see a diff") do
  expect(page).to_not have_css(".diff")
end

Then("I should see {string}") do |value|
  expect(page).to have_text(value)
end

Then("I should see the list of host editions referencing my block") do
  shows_list_of_locations
end

When("I select the {string} tab") do |label|
  click_link label
end

Then("I should see a summary card entitled {string}") do |card_title|
  @summary_block = find(".govuk-summary-card", text: card_title)
end

Then("I should see {string} as a previous value in the summary card") do |value|
  expect_removed_content_in_block(value, @summary_block)
end

Then("I should see {string} as a new value in the summary card") do |value|
  expect_added_content_in_block(value, @summary_block)
end

When("I open the full {string} summary card attributes") do |object_type|
  @summary_details = find("details", text: "All #{object_type} attributes")
  summary = @summary_details.find("summary")
  summary.click
end

Then("I should see {string} as a previous value in the summary details") do |value|
  expect_removed_content_in_block(value, @summary_details)
end

Then("I should see {string} as a new value in the summary details") do |value|
  expect_added_content_in_block(value, @summary_details)
end

Then("I should see {string} in the summary details") do |value|
  expect(@summary_details).to have_text(value)
end

def expect_removed_content_in_block(value, block = page)
  expect(block).to have_css("[aria-label=\"removed content\"]", text: /#{value}/)
end

def expect_added_content_in_block(value, block = page)
  expect(block).to have_css("[aria-label=\"added content\"]", text: /#{value}/)
end
