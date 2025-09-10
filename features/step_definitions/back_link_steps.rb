Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: document_path(@content_block.document),
  )
end

Then(/^I should see a back link to the "([^"]*)" step$/) do |step|
  @content_block ||= Edition.last
  link = if step == "edit"
           new_document_edition_path(@content_block.document)
         else
           workflow_path(
             @content_block.document.editions.last,
             step:,
           )
         end
  expect(page).to have_link("Back", href: link)
end
