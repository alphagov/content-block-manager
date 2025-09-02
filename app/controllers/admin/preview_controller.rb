class Admin::PreviewController < Admin::BaseController
  include GovspeakPreviewHelper

  def preview
    if Govspeak::HtmlValidator.new(params[:body]).valid?
      render layout: false
    else
      render plain: "Content contains possible XSS exploits", status: :forbidden
    end
  end
end
