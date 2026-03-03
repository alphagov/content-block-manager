class BlockPreview::DynamicPreviewController < BlockPreview::ApplicationController
  include ContentBlockManager::AuthenticatesWithJWT

  layout "fullscreen_preview"

  def show() end

private

  def block
    document = Document.find(params[:document_id])
    edition = document.latest_published_edition
    @block ||= ContentBlock.from_edition_id(edition.id)
  end
end
