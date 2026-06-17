class Api::BlocksController < Api::ApplicationController
  def search
    return invalid_page_error if invalid_page?

    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result, request.original_url)
  end

  def render_block
    embed_code = params[:embed_code]
    base_embed_code = embed_code.gsub(/[\/#][^}]+/, "")
    block = ContentBlock.from_embed_code(base_embed_code)
    if block
      render html: block.render(embed_code)
    else
      not_found_page_error "Content block not found for embed code: #{embed_code}"
    end
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword, :page)
  end

  def invalid_page?
    return false if params[:page].blank?

    page = Integer(params[:page], exception: false)
    page.nil? || page < 1
  end

  def not_found_page_error(message)
    render json: { error: message }, status: :not_found
  end

  def invalid_page_error
    render json: { error: "page must be a positive integer" }, status: :bad_request
  end
end
