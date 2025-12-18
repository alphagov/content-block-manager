class Edition::Details::Fields::ObjectComponent < Edition::Details::Fields::BaseComponent
private

  def name_for_field(field)
    field.name_attribute
  end

  def id_for_field(field)
    field.id_attribute
  end

  def errors_for_field(field)
    errors_for(edition.errors, field.error_key.to_sym)
  end

  def value_for_field(field)
    field_value = value&.fetch(field.name, nil)
    return field.default_value if edition.document.is_new_block? && field_value.nil?

    field_value
  end
end
