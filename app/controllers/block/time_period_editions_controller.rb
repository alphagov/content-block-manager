module Block
  class TimePeriodEditionsController < BlocksController
    def new
      @edition = Block::TimePeriodEdition.new
      @edition.build_document(block_type:)
    end

    def create; end

    def show; end

  private

    def block_type
      Block::Document.block_types[:time_period]
    end
  end
end
