class Edition::Details::Fields::ObjectComponent < Edition::Details::Fields::BaseComponent
private

  def component_args(field)
    {
      edition:,
      field:,
      value: value_for_field(field),
      schema:,
    }
  end

  def value_for_field(field)
    field_value = value&.fetch(field.name, nil)
    return field.default_value if edition.document.is_new_block? && field_value.nil?

    field_value
  end
end
