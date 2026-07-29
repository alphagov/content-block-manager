class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result)
  end

  def render_block
    embed_code = params[:embed_code]
    block = ContentBlock.from_embed_code(Rack::Utils.unescape_path(embed_code.to_s))
    return not_found_page_error "Content block not found for embed code: #{embed_code}" if block.nil?

    render html: block.render(embed_code)
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword)
  end

  def not_found_page_error(message)
    render json: { error: message }, status: :not_found
  end
end
