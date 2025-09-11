class Edition::Details::EmbeddedObjects::FormComponent < Edition::Details::FormComponent
  def initialize(edition:, subschema:, params:, object_title: nil)
    @edition = edition
    @subschema = subschema
    @params = params || {}
    @object_title = object_title
  end

private

  attr_reader :edition, :subschema, :params, :object_title

  def schema
    @subschema
  end

  def component_args(field)
    {
      edition:,
      field: field,
      subschema:,
      value: params[field.name],
      object_title:,
    }.compact
  end
end
