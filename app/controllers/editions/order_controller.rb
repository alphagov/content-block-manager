class Editions::OrderController < BaseController
  include Workflow::Steps

  def edit
    @redirect_path = params[:redirect_path] || request.referer
    @order = params[:order] || @edition.details["order"] || @edition.default_order
  end

  def update
    @edition.details["order"] = params[:order]
    @edition.save!

    redirect_to "#{params[:redirect_path]}?preview=true"
  end
end
