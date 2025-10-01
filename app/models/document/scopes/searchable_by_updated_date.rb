module Document::Scopes::SearchableByUpdatedDate
  extend ActiveSupport::Concern

  included do
    scope :last_updated_after, ->(date) { joins(:latest_edition).where("editions.updated_at >= ?", date) }
    scope :last_updated_before, ->(date) { joins(:latest_edition).where("editions.updated_at <= ?", date) }
  end
end
