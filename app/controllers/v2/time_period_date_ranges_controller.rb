module V2
  class TimePeriodDateRangesController < ApplicationController
    before_action :set_document
    before_action :set_edition

    def edit; end

    def update
      if @edition.update(edition_params)
        redirect_to v2_time_period_edition_path(@edition.id),
                    notice: I18n.t("v2/time_period_edition.create.success")
      else
        @error_summary_errors = @edition.errors.map do |error|
          {
            text: error.message,
            href: "##{error.attribute.to_s.tr('.', '_')}",
          }
        end
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def set_document
      @document = V2::Document.find(params[:document_id])
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
