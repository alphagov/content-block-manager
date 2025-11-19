module Document::Scopes::SearchableByUpdatedDate
  extend ActiveSupport::Concern

  included do
    scope :last_updated_after, lambda { |date|
      joins(:editions)
      .merge(Edition.most_recent_for_document)
      .where("editions.updated_at >= ?", date)
    }
    scope :last_updated_before, lambda { |date|
      joins(:editions)
        .merge(Edition.most_recent_for_document)
        .where("editions.updated_at <= ?", date)
    }
  end
end
