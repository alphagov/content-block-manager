class Api::BlockPresenter
  class << self
    def present(block)
      new(block).present
    end

    def present_collection(blocks)
      blocks.map { |block| present(block) }
    end
  end

  def initialize(block)
    @block = block
  end

  def present
    {
      title: @block.title,
      block_type: @block.block_type,
      organisation: {
        name: @block.lead_organisation.name,
        content_id: @block.lead_organisation.id,
      },
      state: "published",
      embed_code: @block.embed_code,
      formats: @block.formats,
    }
  end
end
