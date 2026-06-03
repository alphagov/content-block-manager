class Api::BlocksController < Api::ApplicationController
  def blocks_search
    return invalid_page_error if invalid_page?

    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result, request.original_url)
  end

  def blocks_render
    parsed_query = Rack::Utils.parse_query(request.query_string)
    embed_codes = (
      Array(parsed_query["embed_codes[]"]) +
      Array(parsed_query["embed_codes"]) +
      Array(params[:embed_codes])
    ).filter_map(&:presence).uniq

    rendered_blocks = embed_codes.each_with_object({}) do |embed_code, hash|
      base_embed_code_for_lookup = embed_code.gsub(/[\/#][^}]+/, "")
      next if base_embed_code_for_lookup.blank?

      block = ContentBlock.from_embed_code(base_embed_code_for_lookup)
      next unless block

      hash[embed_code] = {
        title: block.title,
        block_type: block.block_type,
        html: block.render(embed_code),
      }
    end

    render json: { rendered_blocks: }
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

  def invalid_page_error
    render json: { error: "page must be a positive integer" }, status: :bad_request
  end
end
