module Edition::ValidatesUniquenessOfTitle
  extend ActiveSupport::Concern

  included do
    attr_accessor :accept_risk_of_duplicate_title

    validate :title_unique_across_documents, if: :should_validate_uniqueness_of_title?
  end

  def should_validate_uniqueness_of_title?
    accept_risk_of_duplicate_title.blank? && !document.has_published_edition?
  end

  def title_unique_across_documents
    return if title.blank?

    existing = Edition.where(title:).where.not(document_id:).exists?
    errors.add(:title, I18n.t("activerecord.errors.models.edition.title.not_unique")) if existing
  end
end
