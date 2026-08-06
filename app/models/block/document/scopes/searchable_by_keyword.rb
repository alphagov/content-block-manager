module Block::Document::Scopes::SearchableByKeyword
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model
    pg_search_scope :with_keyword,
                    against: %i[embed_code],
                    associated_against: {
                      editions: %i[title description instructions_to_publishers],
                    }
  end
end
