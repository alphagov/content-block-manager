class BlockPreview::PreviewController < BlockPreview::ApplicationController
  def show
    host_content_id = params[:host_content_id]
    @block = ContentBlock.from_edition_id(params[:edition_id])
    @preview_content = BlockPreview::PreviewContent.new(
      content_id: host_content_id,
      block: @block,
      base_path: params[:base_path],
      locale: params[:locale],
    )
  end
end
