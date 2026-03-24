When(/^I visit the preview page for the block and the (draft|published) host document$/) do |state|
  @state = state
  block = ContentBlock.from_edition_id(@content_block.id)
  visit BlockPreview::Engine.routes.url_helpers.host_content_preview_path(
    edition_id: block.id,
    host_content_id: @current_host_document["host_content_id"],
    locale: "en",
    state:,
  )
end

Then("I should see the state of the host document") do
  expect(page).to have_css("strong.govuk-tag", text: @state.titleize)
end
