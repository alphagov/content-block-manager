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
        redirect_to v2_time_period_edition_path(@edition.id),
                    notice: I18n.t("block/time_period_edition.create.success")
      else
        render :new, status: :unprocessable_content
      end
    end

    def show; end

    def edit
      @edition = V2::TimePeriodEdition.find(params[:id])
    end

    def update; end

  private

    def block_type
      V2::Document.block_types[:time_period]
    end
  end
end
