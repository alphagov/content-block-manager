class ContentBlock
  class << self
    def from_content_id_alias(content_id_alias)
      document = Document.find(content_id_alias)
      edition = document.most_recent_edition
      ContentBlock.new(edition)
    end
  end

  def initialize(edition)
    @edition = edition
  end

  delegate :title, :state, :details, :document, :auth_bypass_id, :content_id, :render, to: :edition
  delegate :schema, to: :document
  delegate :embeddable_as_block?, to: :schema

  def block_type
    schema.name
  end

  def published_block
    @published_block ||= document.latest_published_edition ? ContentBlock.new(document.latest_published_edition) : nil
  end

private

  attr_reader :edition
end
