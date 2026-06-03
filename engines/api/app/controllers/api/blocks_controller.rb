class Api::BlocksController < Api::ApplicationController
  def search
    return invalid_page_error if invalid_page?

    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result, request.original_url)
  end

  # named _render to avoid collision with the core framework render method
  def _render
    embed_codes = params.permit(embed_codes: [])[:embed_codes] || []

    rendered_blocks = embed_codes.each_with_object({}) do |embed_code, hash|
      base_embed_code_for_lookup = embed_code.gsub(/[\/#][^}]+/, "")
      next if base_embed_code_for_lookup.blank?

      document = Document.find_by(embed_code: base_embed_code_for_lookup)
      next unless document&.most_recent_edition

      block = ContentBlock.new(document.most_recent_edition)
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
