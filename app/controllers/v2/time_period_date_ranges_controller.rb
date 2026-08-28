module V2
  class TimePeriodDateRangesController < ApplicationController
    before_action :set_edition

    def edit; end

    def update; end

  private

    def set_edition
      @edition = @document.time_period_editions.find(params[:id])
    end

  end
end
