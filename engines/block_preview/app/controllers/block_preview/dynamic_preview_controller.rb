class BlockPreview::DynamicPreviewController < BlockPreview::ApplicationController
  include ContentBlockManager::AuthenticatesWithJWT

  layout "fullscreen_preview"

  def show
    host_content_id = params[:host_content_id]
    @block = block
    @preview_content = BlockPreview::PreviewContent.new(
      content_id: host_content_id,
      block: @block,
      base_path: params[:base_path],
      locale: params[:locale] || "en",
    )
  end

private

  def block
    document = Document.find(params[:document_id])
    edition = document.latest_published_edition
    @block ||= ContentBlock.from_edition_id(edition.id)
  end
end
