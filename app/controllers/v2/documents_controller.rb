module V2
  class DocumentsController < ApplicationController
    def index
      @filters = params.slice(:keyword, :block_type, :lead_organisation, :page, :last_updated_to, :last_updated_from)
        .permit!
        .to_h

      if @filters.any?
        @filter = V2::Document::DocumentFilter.new(@filters)

        begin
          @documents = @filter.call
          render :index
        rescue V2::Document::DocumentFilter::InvalidFiltersError => e
          @documents = V2::Document::DocumentFilter.new({}).call
          @errors = e.errors
          @error_summary_errors = @errors.map { |error| { text: error.full_message, href: "##{error.attribute}" } }
          render :index
        end
      else
        redirect_to v2_documents_path(default_filters)
      end
    end

  private

    def default_filters
      { lead_organisation: "" }
    end
  end
end
