class ContentBlock
  class Query
    DEFAULT_PAGE_SIZE = 10
    Result = Data.define(:blocks, :current_page, :total_pages, :total_count)

    def self.call(filters = {})
      new(filters).results
    end

    def initialize(filters)
      @filters = filters
    end

    def results
      Result.new(
        blocks: paginated_results.map { |document| ContentBlock.new(document.most_recent_edition) },
        current_page: paginated_results.current_page,
        total_pages: paginated_results.total_pages,
        total_count: paginated_results.total_count,
      )
    end

  private

    attr_reader :filters

    def paginated_results
      @paginated_results ||= unpaginated_results.page(page).per(DEFAULT_PAGE_SIZE)
    end

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
