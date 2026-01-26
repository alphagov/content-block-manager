class FactCheck::UngroupedSubschemaDiffComponent < ViewComponent::Base
  def initialize(block:, subschema:)
    @block = block
    @object_type = subschema.id
    @embedded_objects = block.details.fetch(@object_type, {})
  end

private

  attr_reader :block, :edition, :embedded_objects, :object_type

  def metadata_items(block, object_title)
    block_details(block, object_title)
      .reject { |k, v| v.blank? || block_display_fields.include?(k) }
  end

  def block_items(block, object_title)
    block_details(block, object_title)
      .select { |k, v| v.present? && block_display_fields.include?(k) }
      .sort_by { |k, _v| schema.field_ordering_rule(k) }.to_h
  end

  def block_details(block, object_title)
    block.details.dig(object_type, object_title) || {}
  end

  def block_display_fields
    @block_display_fields ||= schema.block_display_fields
  end

  def schema
    @schema ||= block.document.schema.subschema(object_type)
  end
end
