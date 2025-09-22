class Edition::Details::Fields::BSLGuidanceComponent < Edition::Details::Fields::ObjectComponent
  def show_field
    field.nested_field("show")
  end

  def value_field
    field.nested_field("value")
  end

  def label_for(field_name)
    helpers.humanized_label(schema_name: schema.block_type, relative_key: field_name, root_object: "telephones.bsl_guidance")
  end
end
