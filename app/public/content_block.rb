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

  delegate :title, to: :edition

  def block_type
    edition.document.schema.name
  end

private

  attr_reader :edition
end
