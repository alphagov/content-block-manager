module Api
  class ResultsPresenter
    class << self
      def present(result)
        new(result).present
      end
    end

    def initialize(result)
      @result = result
    end

    def present
      {
        results: BlockPresenter.present_collection(result.blocks),
      }
    end

  private

    attr_reader :result
  end
end
