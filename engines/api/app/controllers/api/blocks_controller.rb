class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(filters)
    filtered_result = filter_testing_artefacts(result)
    render json: Api::ResultsPresenter.present(filtered_result)
  end

  def render_block
    embed_code = params[:embed_code]
    block = ContentBlock.from_embed_code(Rack::Utils.unescape_path(embed_code.to_s))
    return not_found_page_error "Content block not found for embed code: #{embed_code}" if block.nil? || testing_artefact_hidden?(block)

    render html: block.render(embed_code)
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword)
  end

  def filter_testing_artefacts(result)
    return result if Current.user&.is_e2e_user?

    filtered_blocks = result.blocks.reject { |block| block.document.testing_artefact? }
    ContentBlock::Query::Result.new(blocks: filtered_blocks)
  end

  def testing_artefact_hidden?(block)
    block.document.testing_artefact? && !Current.user&.is_e2e_user?
  end

  def not_found_page_error(message)
    render json: { error: message }, status: :not_found
  end
end
