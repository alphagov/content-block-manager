class Edition::Details::Fields::TextareaComponent < Edition::Details::Fields::BaseComponent
  def initialize(nested_object_key: nil, **args)
    @nested_object_key = nested_object_key

    super(**args)
  end

  attr_reader :edition, :nested_object_key, :field, :subschema, :errors

  def govspeak_enabled?
    return false unless nested_object_key

    subschema.govspeak_enabled?(nested_object_key: nested_object_key, field_name: field.name)
  end

  def name_attribute
    return name if nested_object_key.blank?

    "edition[details][#{subschema_block_type}][#{nested_object_key}][#{field.name}]"
  end

  def id_attribute
    return id if nested_object_key.blank?

    "#{PARENT_CLASS}_details_#{subschema_block_type}_#{nested_object_key}_#{field.name}"
  end

  def label_element
    return nested_object_label if nested_object_key

    label
  end

  def hint_text
    nil
  end

  def aria_described_by
    "#{id_attribute}-hint"
  end

  def error_items
    return error_items_for_nested_object if nested_object_key

    errors_for(edition.errors, "details_#{id_suffix}".to_sym)
  end

private

  def nested_object_label
    helpers.humanized_label(
      relative_key: field.name,
      root_object: "#{subschema_block_type}.#{nested_object_key}",
    )
  end

  def error_items_for_nested_object
    errors_for(
      edition.errors,
      "details_#{subschema_block_type}_#{nested_object_key}_#{field.name}".to_sym,
    )
  end
end
