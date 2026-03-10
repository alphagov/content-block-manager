class Edition::Show::EmbeddedObject::SubschemaItemComponent < ViewComponent::Base
  def initialize(edition:, schema_name:, object_type:)
    @edition = edition
    @schema_name = schema_name
    @object_type = object_type
    @block_content = BlockContent.new(edition, schema)
  end

private

  attr_reader :edition, :schema_name, :object_type, :block_content

  def schema
    @schema ||= edition.document.schema.subschema(object_type)
  end

  def embedded_object_present?
    edition.details[object_type].present?
  end
end
