class Document::Show::EmbeddedObjects::SubschemaItemsComponent < ViewComponent::Base
  def initialize(edition:, subschema:)
    @edition = edition
    @subschema = subschema
  end

  def id
    object_type
  end

  def label
    "#{subschema.name.pluralize} (#{embedded_objects.count})"
  end

private

  attr_reader :show_button, :edition, :subschema

  def embedded_objects
    @embedded_objects ||= edition.details.fetch(object_type, {})
  end

  def object_type
    @object_type ||= subschema.id
  end
end
