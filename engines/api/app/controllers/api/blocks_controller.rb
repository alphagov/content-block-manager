class Api::BlocksController < Api::ApplicationController
  def search
    result = ContentBlock::Query.call
    render json: Api::BlockPresenter.present_collection(result)
  end
end
