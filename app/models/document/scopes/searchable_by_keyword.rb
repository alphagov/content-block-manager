module Document::Scopes::SearchableByKeyword
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
    pg_search_scope :with_keyword, associated_against: {
      editions: %i[title details instructions_to_publishers],
    }
  end
end
