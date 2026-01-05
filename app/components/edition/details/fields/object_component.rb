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
      value: helpers.value_for_field(details: value, field:, populate_with_defaults:),
      schema:,
      populate_with_defaults:,
    }
  end
end
