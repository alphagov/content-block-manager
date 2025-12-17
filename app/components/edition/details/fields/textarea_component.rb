class Edition::Details::Fields::TextareaComponent < Edition::Details::Fields::BaseComponent
  def initialize(nested_object_key: nil, **args)
    @nested_object_key = nested_object_key

    super(**args)
  end

  attr_reader :edition, :nested_object_key, :field, :schema, :subschema, :errors

  def label_element
    return nested_object_label if nested_object_key

    label
  end

  def aria_described_by
    "#{field.id_attribute}-hint"
  end

private

  def nested_object_label
    helpers.humanized_label(
      schema_name: schema.block_type,
      relative_key: field.name,
      root_object: "#{subschema_block_type}.#{nested_object_key}",
    )
  end
end
