class Edition::Details::Fields::TextareaComponent < Edition::Details::Fields::BaseComponent
  def initialize(nested_object_key: nil, **args)
    @nested_object_key = nested_object_key

    super(**args)
  end

  attr_reader :edition, :nested_object_key, :field, :schema, :subschema, :errors

  def aria_described_by
    "#{field.id_attribute}-hint"
  end
end
