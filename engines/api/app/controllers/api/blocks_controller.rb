class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result)
  end

  def render_block
    embed_code = params[:embed_code]
    block = ContentBlock.from_embed_code(Rack::Utils.unescape_path(params[:embed_code].to_s))
    if block
      render html: block.render(embed_code)
    else
      not_found_page_error "Content block not found for embed code: #{embed_code}"
    end
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword)
  end

  def not_found_page_error(message)
    render json: { error: message }, status: :not_found
  end
end
