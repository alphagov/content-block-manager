class Api::BlockPresenter
  class OrganisationNotFound < StandardError; end

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
      organisation: organisation,
      state: "published",
      embed_code: @block.embed_code,
      formats: @block.formats,
    }
  end

private

  def organisation
    org = @block.lead_organisation
    unless org
      raise OrganisationNotFound,
            "Organisation not found for block '#{@block.title}'"
    end

    { name: org.name, content_id: org.id }
  end
end
