module Edition::HasLeadOrganisation
  extend ActiveSupport::Concern

  included do
    validates_with OrganisationValidator
  end

  def lead_organisation
    Organisation.find(lead_organisation_id)
  end
end
