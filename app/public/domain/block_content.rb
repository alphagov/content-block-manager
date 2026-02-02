class BlockContent
  def initialize(block, subschema)
    @block = block
    @object_type = subschema.id
    @schema = block&.document&.schema&.subschema(object_type)
    @block_display_fields = @schema&.block_display_fields
  end

  attr_reader :block, :schema, :block_display_fields, :object_type

  def metadata(object_title)
    return unless block

    block_details(block, object_title)
      .reject { |k, v| v.blank? || block_display_fields.include?(k) }
  end

  def fields(object_title)
    return unless block

    block_details(block, object_title)
      .select { |k, v| v.present? && block_display_fields.include?(k) }
      .sort_by { |k, _v| schema.field_ordering_rule(k) }.to_h
  end

private

  def block_details(block, object_title)
    block.details.dig(object_type, object_title) || {}
  end
end
