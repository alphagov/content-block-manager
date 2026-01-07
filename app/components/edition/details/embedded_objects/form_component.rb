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

  def context(field)
    Edition::Details::Fields::Context.new(
      edition:,
      field: field,
      schema:,
      subschema:,
      object_title:,
      populate_with_defaults:,
      details: params,
    )
  end
end
