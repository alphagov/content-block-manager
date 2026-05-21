class Api::BlocksController < Api::ApplicationController
  def search
    return invalid_page_error if invalid_page?

    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result, request.original_url)
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
