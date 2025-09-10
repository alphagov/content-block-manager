class Editions::HostContentController < BaseController
  def preview
    host_content_id = params[:host_content_id]
    @edition = Edition.find(params[:id])
    @preview_content = PreviewContent.for_content_id(
      content_id: host_content_id,
      edition: @edition,
      base_path: params[:base_path],
      locale: params[:locale],
    )
  end
end
