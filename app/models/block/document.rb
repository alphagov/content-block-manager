module Block
  class Document < ApplicationRecord
    self.table_name = "block_documents"

    has_many :editions, class_name: "Block::Edition", foreign_key: :block_document_id, dependent: :destroy

    before_validation :generate_content_id, on: :create
    before_validation :generate_embed_code, on: :create

    def title
      editions.order(created_at: :desc).first&.title
    end

    def built_embed_code
      "{{embed:content_block:#{block_type}:#{content_id}}}"
    end

    def embed_code_for_field(field_path)
      "{{embed:content_block:#{block_type}:#{content_id}:#{field_path}}}"
    end

  private

    def generate_content_id
      self.content_id ||= SecureRandom.uuid
    end

    def generate_embed_code
      self.embed_code ||= built_embed_code
    end
  end
end
