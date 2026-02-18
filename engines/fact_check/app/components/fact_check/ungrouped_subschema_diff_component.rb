class FactCheck::UngroupedSubschemaDiffComponent < ViewComponent::Base
  def initialize(block:, subschema:)
    @block = block
    @object_type = subschema.id
    @embedded_objects = block.details.fetch(@object_type, {})
    @block_content_new = BlockContent.new(block, subschema)
    @block_content_published = BlockContent.new(block.published_block, subschema)
    @schema = block.document.schema.subschema(object_type)
  end

private

  attr_reader :block, :embedded_objects, :object_type, :block_content_new, :block_content_published, :schema

  def combined_metadata_for_key(key)
    CombinedEditionDetails.new(
      published_details: block_content_published.metadata(key),
      new_details: block_content_new.metadata(key),
    ).content
  end

  def combined_fields_for_key(key)
    CombinedEditionDetails.new(
      published_details: block_content_published.fields(key),
      new_details: block_content_new.fields(key),
    ).content
  end
end
