class PublishedEditionController < BaseController
  def show
    @document = Document.find(params[:id])
    @edition = @document.latest_published_edition

    raise "Document #{@document.id} has no published edition" unless @edition

    @schema = Schema.find_by_block_type(@document.block_type)
    @content_block_versions = @document.versions
    @order = params[:order]
    @page = params[:page]

    @host_content_items = HostContentItem.for_document(
      @document,
      order: @order,
      page: @page,
    )

    render "documents/show"
  end
end
