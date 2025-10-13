class DocumentsController < BaseController
  def index
    if params_filters.any?
      @filters = params_filters
      filter_result = Document::DocumentFilter.new(@filters)
      @documents = filter_result.paginated_documents
      unless filter_result.valid?
        @errors = filter_result.errors
        @error_summary_errors = @errors.map { |error| { text: error.full_message, href: "##{error.attribute}_3i" } }
      end
      render :index
    else
      redirect_to root_path(default_filters)
    end
  end

  def show
    @document = Document.find(params[:id])
    @schema = Schema.find_by_block_type(@document.block_type)
    @content_block_versions = @document.versions
    @order = params[:order]
    @page = params[:page]

    @host_content_items = HostContentItem.for_document(
      @document,
      order: @order,
      page: @page,
    )
  end

  def content_id
    document = Document.where(content_id: params[:content_id]).first

    if document.present?
      redirect_to document_path(document)
    else
      raise ActiveRecord::RecordNotFound, "Could not find Content Block with Content ID #{params[:content_id]}"
    end
  end

  def new
    @schemas = Schema.all
  end

  def new_document_options_redirect
    if params[:block_type].present?
      redirect_to new_edition_path(block_type: params.require(:block_type))
    else
      redirect_to new_document_path, flash: { error: I18n.t("activerecord.errors.models.document.attributes.block_type.content_block.blank") }
    end
  end

private

  def params_filters
    params.slice(:keyword, :block_type, :lead_organisation, :page, :last_updated_to, :last_updated_from)
          .permit!
          .to_h
  end

  def default_filters
    { lead_organisation: "" }
  end
end
