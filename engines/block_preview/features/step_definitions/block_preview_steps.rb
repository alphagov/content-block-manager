When("I visit the preview page for the block and the host document") do
  block = ContentBlock.from_edition_id(@content_block.id)
  visit BlockPreview::Engine.routes.url_helpers.host_content_preview_path(
    edition_id: block.id,
    host_content_id: @current_host_document["host_content_id"],
    locale: "en",
  )
end
