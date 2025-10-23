class Edition::Details::EmbeddedObjects::FormComponent < Edition::Details::FormComponent
  def initialize(edition:, schema:, subschema:, params:, populate_with_defaults:, object_title: nil)
    @edition = edition
    @schema = schema
    @subschema = subschema
    @params = params || {}
    @populate_with_defaults = populate_with_defaults
    @object_title = object_title
  end

private

  attr_reader :edition, :schema, :subschema, :params, :object_title, :populate_with_defaults

  def fields
    subschema.fields
  end

  def component_args(field)
    {
      edition:,
      field: field,
      schema:,
      subschema:,
      value: helpers.value_for_field(details: params, field:, populate_with_defaults:),
      object_title:,
    }.compact
  end
end
