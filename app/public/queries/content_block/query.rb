class ContentBlock
  class Query
    DEFAULT_PAGE_SIZE = 10

    def self.call(filters = {})
      new(filters).results
    end

    def initialize(filters)
      @filters = filters
    end

    def results
      unpaginated_results.page(page)
                         .per(DEFAULT_PAGE_SIZE)
                         .map { |document| ContentBlock.new(document.most_recent_edition) }
    end

  private

    attr_reader :filters

    def page
      filters[:page].presence || 1
    end

    def unpaginated_results
      Document.joins(:editions)
              .merge(Edition.most_recent_for_document)
              .merge(Edition.published)
              .extending(Scopes)
              .by_block_type(filters[:block_type])
              .by_lead_organisation_id(filters[:lead_organisation_id])
              .by_keyword(filters[:keyword])
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

        where("documents.id IN (?)", Document.with_keyword(keyword).pluck(:id))
      end
    end
  end
end
