class Editions::FactCheckPreviewLinkController < BaseController
  def update
    edition = Edition.find(params[:id])
    edition.set_auth_bypass_id
    edition.save!

    redirect_to document_path(edition.document), notice: "New preview link generated"
  end
end
