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

  def label_for(field)
    helpers.humanized_label(schema_name: schema.block_type, relative_key: field.name, root_object: field.send(:parent_schemas).map(&:id).join("."))
  end

  def hint_text_for(field)
    hint_text&.fetch(field.name, nil)
  end
end
