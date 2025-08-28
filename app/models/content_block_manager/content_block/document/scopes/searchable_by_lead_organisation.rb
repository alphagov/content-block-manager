module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByLeadOrganisation
    extend ActiveSupport::Concern

    included do
      scope :with_lead_organisation,
            lambda { |id|
              latest_edition.where("content_block_editions.lead_organisation_id = :id", id:)
            }
    end
  end
end
