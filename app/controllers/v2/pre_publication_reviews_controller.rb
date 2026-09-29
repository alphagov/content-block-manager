module V2
  class PrePublicationReviewsController < BaseController
    before_action :set_edition
    helper_method :page_title

    def new; end

  private

    def set_edition
      edition_id = params[:time_period_edition_id]

      @edition = V2::Edition.find(edition_id)
    end

    def page_title
      block_name = @edition.document.block_type.humanize.downcase
      "Review #{block_name}"
    end
  end
end
