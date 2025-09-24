class Document::Show::EmbeddedObjects::SubschemaItemsComponent < ViewComponent::Base
  def initialize(edition:, schema:, subschema:)
    @edition = edition
    @schema = schema
    @subschema = subschema
  end

  def id
    object_type
  end

  def label
    "#{subschema.name.singularize.capitalize} (#{embedded_objects.count})"
  end

private

  attr_reader :show_button, :edition, :schema, :subschema

  def embedded_objects
    @embedded_objects ||= edition.details.fetch(object_type, {})
  end

  def object_type
    @object_type ||= subschema.id
  end
end
