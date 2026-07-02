class ContentBlock
  class Query
    Result = Data.define(:blocks)

    def self.call(filters = {})
      new(filters).results
    end

    def initialize(filters)
      @filters = filters
    end

    def results
      Result.new(
        blocks: unpaginated_results.preload(:latest_published_edition).map { |document| ContentBlock.new(document.latest_published_edition) },
      )
    end

  private

    attr_reader :filters

    def unpaginated_results
      Document.joins(:editions)
              .merge(Edition.most_recent_published_for_document)
              .extending(Scopes)
              .by_block_type(filters[:block_type])
              .by_lead_organisation_id(filters[:lead_organisation_id])
              .by_keyword(filters[:keyword])
              .order(sort_order)
    end

    def sort_order
      "editions.created_at DESC"
    end

    module Scopes
      def by_block_type(block_type)
        return self if block_type.blank?

        where("block_type = ?", block_type)
      end

      def by_lead_organisation_id(lead_organisation_id)
        return self if lead_organisation_id.blank?

        where("editions.lead_organisation_id = ?", lead_organisation_id)
      end

      def by_keyword(keyword)
        return self if keyword.blank?

        where(id: Document.with_keyword(keyword).select(:id))
      end
    end
  end
end
