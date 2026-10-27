module V2
  class DomainEvent < ApplicationRecord
    belongs_to :document, class_name: "V2::Document", foreign_key: :v2_document_id
    belongs_to :edition, class_name: "V2::Edition", foreign_key: :v2_edition_id, optional: true
    belongs_to :version, class_name: "V2::Version", foreign_key: :v2_version_id, optional: true

    belongs_to :user, class_name: "User"

    EVENT_NAMES = %w[
      edition.state_transition.succeeded
      edition.fact_check.performed
      edition.fact_check.skipped
      edition.review.performed
      edition.review.skipped
    ].freeze

    validates :name, presence: true
    validate :ensure_name_valid

    def ensure_name_valid
      return if name.in? EVENT_NAMES

      errors.add :name, "not known"
    end

    def self.record(document:, user:, name:, metadata: {}, edition: nil, version: nil)
      create!(
        document: document,
        user: user,
        name: name,
        metadata: metadata,
        edition: edition,
        version: version,
      ).tap do |event|
        Rails.logger.info("V2::DomainEvent: recording #{event.inspect}")
      end
    end
  end
end
