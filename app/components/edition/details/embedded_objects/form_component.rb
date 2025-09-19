class Edition::Details::EmbeddedObjects::FormComponent < Edition::Details::FormComponent
  def initialize(edition:, schema:, subschema:, params:, object_title: nil)
    @edition = edition
    @schema = schema
    @subschema = subschema
    @params = params || {}
    @object_title = object_title
  end

private

  attr_reader :edition, :schema, :subschema, :params, :object_title

  def fields
    subschema.fields
  end

  def component_args(field)
    {
      edition:,
      field: field,
      schema:,
      subschema:,
      value: params[field.name],
      object_title:,
    }.compact
  end
end
