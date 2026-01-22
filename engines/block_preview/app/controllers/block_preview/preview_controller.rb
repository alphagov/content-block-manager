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

  def form_handler
    form_submission = BlockPreview::FormSubmission.new(
      url: params[:url].to_s,
      body: params.permit(body: {}).fetch(:body).to_h,
      method: params[:method].to_s,
    )
    block = ContentBlock.from_edition_id(params[:edition_id])

    redirect_to host_content_preview_path(
      edition_id: block.id,
      host_content_id: params[:host_content_id],
      locale: params[:locale],
      base_path: form_submission.redirect_path,
    )
  rescue BlockPreview::FormSubmission::UnexpectedResponseError, BlockPreview::FormSubmission::UnexpectedUrlError
    head :bad_request
  end
end
