module V2
  class TimePeriodDateRangesController < ApplicationController
    before_action :set_document
    before_action :set_edition

    def edit; end

    def update; end

  private

    def set_document
      @document = V2::Document.find(params[:document_id])
    end

    def set_edition
      @edition = @document.time_period_editions.find(params[:id])
    end

  end
end
