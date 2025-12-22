class Edition::Details::Fields::ObjectComponent < Edition::Details::Fields::BaseComponent
  def show_field
    @show_field ||= field.show_field
  end

  def conditionally_revealed?
    field.show_field.present?
  end

  def nested_fields
    conditionally_revealed? ? field.nested_fields.reject { |f| f.name == show_field.name } : field.nested_fields
  end

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
