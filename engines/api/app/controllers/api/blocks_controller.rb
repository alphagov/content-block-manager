class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call(filters)
    render json: Api::BlockPresenter.present_collection(result)
  end

private

  def filters
    params.permit(:block_type, :lead_organisation_id)
  end
end
