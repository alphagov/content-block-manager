class Editions::FactCheckPreviewLinkController < BaseController
  def update
    @edition = Edition.find(params[:id])
    @edition.set_auth_bypass_id
    @edition.save!

    respond_to do |format|
      format.html { redirect_to document_path(@edition.document), notice: "New preview link generated" }
      format.turbo_stream { render :show }
    end
  end
end
