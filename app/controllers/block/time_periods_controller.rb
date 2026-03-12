module Block
  class TimePeriodsController < ApplicationController
    def new
      @document = Block::Document.new(block_type: "time_period")
      @edition = @document.time_period_editions.build
    end

    def create
      @document = Block::Document.new(document_params)
      @edition = @document.time_period_editions.build(edition_params)

      if @document.save
        redirect_to block_time_period_path(@edition), notice: "Time period was successfully created."
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
        redirect_to block_time_period_path(@edition), notice: "Time period was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def document_params
      params.require(:block_document).permit(:sluggable_string, :block_type)
    end

    def edition_params
      params.require(:block_time_period_edition).permit(
        :title,
        :description,
        :instructions_to_publishers,
        :lead_organisation_id,
        date_range_attributes: %i[id start end],
      )
    end
  end
end
