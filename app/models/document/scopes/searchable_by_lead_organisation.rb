module Document::Scopes::SearchableByLeadOrganisation
  extend ActiveSupport::Concern

  included do
    scope :with_lead_organisation,
          lambda { |id|
            joins(:editions).merge(Edition.most_recent_for_document)
              .where("editions.lead_organisation_id = :id", id:)
          }
  end
end
