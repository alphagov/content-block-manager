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
          @error_summary_errors = [{ text: flash[:error] }] if flash[:error]
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

    def show
      @document = Document.find(params[:id])
      @edition = @document.most_recent_edition

      # This is temporary to allow for feature testing until state is properly implemented
      @edition.state = params[:state] if params[:state]

      render :show
    rescue ActiveRecord::RecordNotFound
      redirect_to v2_documents_path(default_filters),
                  flash: { error: I18n.t("v2.document.show.errors.document_not_found", id: params[:id]) }
    end

  private

    def default_filters
      { lead_organisation: "" }
    end
  end
end
