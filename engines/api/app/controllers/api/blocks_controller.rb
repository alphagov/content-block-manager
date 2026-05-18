class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(filters)
    render json: Api::ResultsPresenter.present(result, request.original_url)
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id, :keyword, :page)
  end
end
