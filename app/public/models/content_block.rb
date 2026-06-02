class ContentBlock
  class << self
    def from_content_id_alias(content_id_alias)
      document = Document.find(content_id_alias)
      edition = document.most_recent_edition
      ContentBlock.new(edition)
    end

    def from_edition_id(edition_id)
      edition = Edition.find(edition_id)
      ContentBlock.new(edition)
    end

    def from_embed_code(embed_code)
      document = Document.find_by(embed_code:)
      return nil unless document&.most_recent_edition

      ContentBlock.new(document.most_recent_edition)
    end
  end

  def initialize(edition)
    @edition = edition
  end

  delegate :id, :title, :state, :details, :document, :auth_bypass_id, :content_id, :render, :lead_organisation, to: :edition
  delegate :schema, :embed_code, to: :document
  delegate :embeddable_as_block?, :formats, to: :schema

  def block_type
    schema.name
  end

  def published_block
    @published_block ||= document.latest_published_edition ? ContentBlock.new(document.latest_published_edition) : nil
  end

private

  attr_reader :edition
end
