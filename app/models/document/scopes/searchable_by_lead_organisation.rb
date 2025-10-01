module Document::Scopes::SearchableByLeadOrganisation
  extend ActiveSupport::Concern

  included do
    scope :with_lead_organisation,
          lambda { |id|
            joins(:latest_edition).where("editions.lead_organisation_id = :id", id:)
          }
  end
end
