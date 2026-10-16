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
        if !has_associated_date_range
          redirect_to edit_v2_time_period_edition_time_period_date_range_path(
            @edition,
          )
        else
          flash[:success] = I18n.t("v2.time_period_edition.update.success")

          redirect_to new_v2_time_period_edition_pre_publication_review_path(@edition)
        end
      else
        render :edit, status: :unprocessable_content
      end
    end

  private

    def block_type
      V2::Document.block_types[:time_period]
    end

    def has_associated_date_range
      @edition.date_range.present?
    end
  end
end
