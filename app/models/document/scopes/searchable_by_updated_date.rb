module Document::Scopes::SearchableByUpdatedDate
  extend ActiveSupport::Concern

  included do
    scope :latest_edition, -> { joins(:editions).where("documents.latest_edition_id = editions.id") }
    scope :from_date, ->(date) { latest_edition.where("editions.updated_at >= ?", date) }
    scope :to_date, ->(date) { latest_edition.where("editions.updated_at <= ?", date) }
  end
end
