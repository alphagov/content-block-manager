class Editions::FactcheckOutcomesController < BaseController
  def new
    @edition = Edition.find(params[:id])
    @title = "Publish block"
    render :new
  end
end
