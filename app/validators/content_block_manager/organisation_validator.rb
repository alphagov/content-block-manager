class ContentBlockManager::OrganisationValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    @edition = edition
    if edition.lead_organisation_id.blank?
      edition.errors.add(:lead_organisation_id, :blank)
    end
  end
end
