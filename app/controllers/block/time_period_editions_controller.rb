module Block
  class TimePeriodEditionsController < BlocksController
    def new
      @edition = Block::TimePeriodEdition.new
      @edition.build_document(block_type:)
    end

    def create
      @edition = Block::TimePeriodEdition.new(edition_params)
      @edition.build_document(block_type:)
      @edition.save!

      redirect_to block_time_period_editions_path,
                  notice: I18n.t("block/time_period_edition.create.success")
    end

    def show; end

  private

    def block_type
      Block::Document.block_types[:time_period]
    end
  end
end
