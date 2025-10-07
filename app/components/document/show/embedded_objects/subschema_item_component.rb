class Document::Show::EmbeddedObjects::SubschemaItemComponent < ViewComponent::Base
  def initialize(edition:, schema_name:, object_type:, object_title:)
    @edition = edition
    @schema_name = schema_name
    @object_type = object_type
    @object_title = object_title
  end

private

  attr_reader :edition, :schema_name, :object_type, :object_title

  def metadata_items
    object.reject { |k, v| v.blank? || block_display_fields.include?(k) }
  end

  def block_items
    object.select { |k, v| v.present? && block_display_fields.include?(k) }
          .sort_by { |k, _v| schema.field_ordering_rule(k) }.to_h
  end

  def block_display_fields
    @block_display_fields ||= schema.block_display_fields
  end

  def schema
    @schema ||= edition.document.schema.subschema(object_type)
  end

  def object
    @object ||= edition.details.dig(object_type, object_title)
  end
end
