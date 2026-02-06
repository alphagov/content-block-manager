class FactCheck::SubschemaGroupDiffComponent < ViewComponent::Base
  def initialize(edition:, schema:, subschema:)
    @block = edition
    @edition = edition
    @schema = schema
    @subschema = subschema

    @block_content_new = BlockContent.new(block, subschema)
    @block_content_published = BlockContent.new(block.published_block, subschema)
    @schema = block.document.schema.subschema(object_type)
  end

  def id
    object_type
  end

  def label
    "#{subschema.name.singularize.capitalize} (#{embedded_objects.count})"
  end

private

  attr_reader :show_button, :edition, :schema, :subschema, :block, :block_content_new, :block_content_published

  def embedded_objects
    @embedded_objects ||= edition.details.fetch(object_type, {})
  end

  def object_type
    @object_type ||= subschema.id
  end
end
