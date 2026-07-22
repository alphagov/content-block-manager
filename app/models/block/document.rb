module Block
  class Document < ApplicationRecord
    extend FriendlyId
    friendly_id :sluggable_string, use: :slugged, slug_column: :content_id_alias, routes: :default

    has_many :editions,
             class_name: "Block::Edition",
             foreign_key: :block_document_id,
             dependent: :destroy,
             inverse_of: :document

    has_many :time_period_editions,
             -> { where(type: "Block::TimePeriodEdition") },
             class_name: "Block::TimePeriodEdition",
             foreign_key: :block_document_id,
             dependent: :destroy,
             inverse_of: :document

    has_one :most_recent_edition,
            -> { most_recent_first },
            foreign_key: :block_document_id,
            class_name: "Block::Edition"

    before_validation :generate_content_id, on: :create
    after_validation :set_content_id_alias_and_embed_code, on: :create

    enum :block_type, { time_period: "time_period" }

    def title
      most_recent_edition&.title
    end

    def built_embed_code
      "{{embed:content_block_#{block_type}:#{content_id_alias}}}"
    end

    def embed_code_for_field(field_path)
      "{{embed:content_block_#{block_type}:#{content_id_alias}/#{field_path}}}"
    end

  private

    def generate_content_id
      self.content_id ||= SecureRandom.uuid
    end

    def set_content_id_alias_and_embed_code
      self.content_id_alias = friendly_id
      self.embed_code = built_embed_code
    end
  end
end
