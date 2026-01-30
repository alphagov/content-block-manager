class Edition::Show::EmbeddedObjects::SubschemaItemComponent < ViewComponent::Base
  def initialize(edition:, schema_name:, object_type:, object_title:)
    @edition = edition
    @schema_name = schema_name
    @object_type = object_type
    @object_title = object_title
    @block_content = BlockContent.new(edition, schema)
  end

private

  attr_reader :edition, :schema_name, :object_type, :object_title, :block_content

  def schema
    @schema ||= edition.document.schema.subschema(object_type)
  end
end
