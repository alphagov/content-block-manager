class Edition::Details::Fields::VideoRelayServiceComponent < Edition::Details::Fields::ObjectComponent
  def show_video_relay_service
    field.nested_field("show")
  end

  def label
    field.nested_field("label")
  end

  def telephone_number
    field.nested_field("telephone_number")
  end

  def source
    field.nested_field("source")
  end

  def label_for(field_name)
    helpers.humanized_label(schema_name: schema.block_type, relative_key: field_name, root_object: "telephones.video_relay_service")
  end
end
