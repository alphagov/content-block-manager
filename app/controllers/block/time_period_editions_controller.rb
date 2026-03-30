module Block
  class TimePeriodEditionsController < ApplicationController
    before_action :set_edition, only: %i[show edit update]
    before_action :set_organisations, only: %i[new create]

    def new
      @edition = Block::TimePeriodEdition.new
      @edition.build_document(block_type: "time_period")
    end

    def create
      @edition = Block::TimePeriodEdition.new(edition_params)
      @edition.build_document(block_type: "time_period") unless @edition.document

      if @edition.save
        redirect_to block_time_period_edition_path(@edition)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end

    def edit; end

    def update; end

  private

    def set_edition
      @edition = Block::TimePeriodEdition.find(params[:id])
    end

    def set_organisations
      @organisations = [{ text: "", value: "" }] +
        Organisation.all.map { |org| { text: org.name, value: org.id } }
    end

    def edition_params
      params.require(:edition).permit(
        :title,
        :description,
        :instructions_to_publishers,
        :lead_organisation_id,
      )
    end
  end
end
