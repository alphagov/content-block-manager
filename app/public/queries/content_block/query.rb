class ContentBlock
  class Query
    def self.call
      Document.joins(:editions)
                  .merge(Edition.most_recent_for_document)
                  .merge(Edition.published)
                  .map { |document| ContentBlock.new(document.most_recent_edition) }
    end
  end
end
