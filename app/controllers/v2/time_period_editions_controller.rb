module V2
  class TimePeriodEditionsController < BaseController
    def new
      @edition = V2::TimePeriodEdition.new
      @edition.build_document(block_type:)
    end

    def create
      @edition = V2::TimePeriodEdition.new(edition_params)
      @edition.build_document(block_type:)

      if @edition.save
        redirect_to edit_v2_time_period_edition_time_period_date_range_path(
          @edition,
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    def show; end

    def edit
      @edition = V2::TimePeriodEdition.find(params[:id])
    end

    def update
      @edition = V2::TimePeriodEdition.find(params[:id])
      @edition.assign_attributes(edition_params.except(:creator))

      if @edition.save
        redirect_to v2_time_period_edition_path(@edition.id),
                    notice: I18n.t("v2/time_period_edition.update.success")
      else
        render :edit, status: :unprocessable_content
      end
    end

  private

    def block_type
      V2::Document.block_types[:time_period]
    end
  end
end
