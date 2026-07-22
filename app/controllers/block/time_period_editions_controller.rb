module Block
  class TimePeriodEditionsController < BlockController
    def new
      @edition = Block::TimePeriodEdition.new
      @document = @edition.build_document(block_type:)
    end

    def create
      @edition = Block::TimePeriodEdition.new(edition_params)
      @edition.document = @edition.build_document(block_type:)
      @edition.save!
      redirect_to block_time_period_editions_path, notice: "Time period edition was successfully created."
    end

    def index; end

  private

    def block_type
      Block::Document.block_types[:time_period]
    end
  end
end
