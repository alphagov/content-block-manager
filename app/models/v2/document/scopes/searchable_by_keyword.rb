module V2::Document::Scopes::SearchableByKeyword
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
    pg_search_scope :where_keyword,
                    against: %i[embed_code],
                    associated_against: {
                      editions: %i[title instructions_to_publishers],
                    }
  end
end
