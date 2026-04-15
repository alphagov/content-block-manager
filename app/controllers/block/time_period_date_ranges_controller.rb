module Block
  class TimePeriodDateRangesController < ApplicationController
    before_action :set_document
    before_action :set_edition

    def show; end

    def edit; end

    def update
      if @edition.update(edition_params)
        redirect_to block_time_period_edition_path(@edition)
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def set_document
      @document = Block::Document.find(params[:document_id])
    end

    def set_edition
      @edition = @document.time_period_editions.find(params[:id])
    end

    def edition_params
      params.require(:edition).permit(
        date_range_attributes: %i[id start end],
      )
    end
  end
end
