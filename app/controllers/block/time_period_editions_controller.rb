module Block
  class TimePeriodEditionsController < BlocksController
    def new; end

    def create; end

    def show; end

  private

    def block_type
      Block::Document.block_types[:time_period]
    end
  end
end
