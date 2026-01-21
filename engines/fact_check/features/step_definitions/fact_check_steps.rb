When("I visit the fact check path for the block") do
  visit FactCheck::Engine.routes.url_helpers.block_path(@content_block.document.content_id_alias)
end

Then("I should see the block's title") do
  expect(page).to have_css("h1", text: @content_block.document.title)
end

Then("I should see {string} as a previous value") do |value|
  expect(page).to have_css("[aria-label=\"removed content\"]", text: /#{value}/)
end

Then("I should see {string} as a new value") do |value|
  expect(page).to have_css("[aria-label=\"added content\"]", text: /#{value}/)
end

Then("I should not see a diff") do
  expect(page).to_not have_css(".diff")
end

Then("I should see {string}") do |value|
  expect(page).to have_text(value)
end
