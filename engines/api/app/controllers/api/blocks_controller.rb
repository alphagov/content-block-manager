class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(
      filters,
      excluded_block_types: ContentBlock.api_excluded_block_types,
      include_testing_artefacts: ContentBlock.current_user_is_e2e?,
    )
    render json: Api::ResultsPresenter.present(result)
  end

  def render_block
    embed_code = params[:embed_code]
    block = ContentBlock.from_embed_code(Rack::Utils.unescape_path(params[:embed_code].to_s))
    return not_found_page_error "Content block not found for embed code: #{embed_code}" if block.nil? || hidden_from_api?(block)

    render html: block.render(embed_code)
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword)
  end

  def hidden_from_api?(block)
    block.document.block_type.in?(ContentBlock.api_excluded_block_types) ||
      !block.visible_to_non_e2e_restricted_api?
  end

  def not_found_page_error(message)
    render json: { error: message }, status: :not_found
  end
end
