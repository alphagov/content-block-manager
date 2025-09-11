class Edition::Details::Fields::GovspeakEnabledTextareaComponent < Edition::Details::Fields::BaseComponent
  def initialize(edition:, value:, nested_object_key:, field:, subschema:)
    @nested_object_key = nested_object_key
    @field = field
    @value = value
    @edition = edition

    super(
      subschema: subschema,
      edition: edition,
      field: field,
      value: value,
    )
  end

  attr_reader :edition, :nested_object_key, :field, :subschema, :errors

  def govspeak_enabled?
    subschema.govspeak_enabled?(nested_object_key: nested_object_key, field_name: field.name)
  end

  def id_attribute
    "#{PARENT_CLASS}_details_#{subschema_block_type}_#{nested_object_key}_#{field.name}"
  end

  def aria_described_by
    "#{id_attribute}-hint"
  end

  def hint_text
    return nil unless govspeak_enabled?

    "Govspeak supported"
  end

  def label
    helpers.humanized_label(
      relative_key: field.name,
      root_object: "#{subschema_block_type}.#{nested_object_key}",
    )
  end

  def name_attribute
    "edition[details][#{subschema_block_type}][#{nested_object_key}][#{field.name}]"
  end

  def error_items
    errors_for(
      edition.errors,
      "details_#{subschema_block_type}_#{nested_object_key}_#{field.name}".to_sym,
    )
  end
end
