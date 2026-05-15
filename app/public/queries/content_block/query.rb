class ContentBlock
  class Query
    module Scopes
      def by_block_type(block_type)
        return self if block_type.blank?

        where("block_type = ?", block_type)
      end

      def by_lead_organisation_id(lead_organisation_id)
        return self if lead_organisation_id.blank?

        where("editions.lead_organisation_id = ?", lead_organisation_id)
      end
    end

    def self.call(filters = {})
      Document.joins(:editions)
                  .merge(Edition.most_recent_for_document)
                  .merge(Edition.published)
                  .extending(Scopes)
                  .by_block_type(filters[:block_type])
                  .by_lead_organisation_id(filters[:lead_organisation_id])
                  .map { |document| ContentBlock.new(document.most_recent_edition) }
    end
  end
end
