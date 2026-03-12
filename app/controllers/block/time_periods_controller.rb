module Block
  class TimePeriodsController < ApplicationController
    def new
      @document = Block::Document.new(
        block_type: "time_period",
        sluggable_string: "time-period-#{SecureRandom.hex(4)}",
      )
      @edition = @document.time_period_editions.build
    end

    def create
      @document = Block::Document.new(
        block_type: "time_period",
        sluggable_string: params.dig(:edition, :document_attributes,
                                     :sluggable_string),
      )
      @edition = @document.time_period_editions.build(edition_params)

      if @document.save
        redirect_to block_time_period_path(@edition),
                    notice: "Time period was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @edition = Block::TimePeriodEdition.find(params[:id])
      @document = @edition.document
    end

    def edit
      @edition = Block::TimePeriodEdition.find(params[:id])
      @document = @edition.document
    end

    def update
      @edition = Block::TimePeriodEdition.find(params[:id])
      @document = @edition.document

      if @edition.update(edition_params)
        redirect_to block_time_period_path(@edition),
                    notice: "Time period was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def edition_params
      params.require(:edition).permit(
        :title,
        :description,
        date_range_attributes: %i[id start end],
      )
    end
  end
end
