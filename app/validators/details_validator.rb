class DetailsValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    @edition = edition

    return false if block_type_blank?

    errors = validate_with_schema(edition)
    errors.each do |e|
      if e["type"] == "required"
        add_blank_errors(e)
      elsif e["type"] == "formatMinimum"
        add_format_minimum_errors(e, edition.schema.block_type)
      elsif %w[format pattern].include?(e["type"])
        add_format_errors(e)
      end
    end
  end

  def add_blank_errors(error)
    missing_keys = error.dig("details", "missing_keys") || []
    missing_keys.each do |k|
      key = key_with_optional_prefix(error, k)
      edition.errors.add(
        "details_#{key}",
        translate_error("blank", k),
      )
    end
  end

  def add_format_minimum_errors(error, block_type)
    attribute, key = get_attribute_and_key_from_error(error)
    minimum_date = resolve_format_minimum_date(error["schema"]["formatMinimum"], block_type)

    edition.errors.add(
      "details_#{key}",
      translate_error("minimum", attribute, minimum_date: minimum_date),
    )
  end

  def resolve_format_minimum_date(format_minimum, block_type)
    return Date.iso8601(format_minimum).to_fs(:long) if format_minimum.is_a?(String)

    translation_path = format_minimum["$ref"].delete_prefix("#").split("/").compact_blank
    I18n.t(
      translation_path.join("."),
      scope: [:edition, :labels, block_type],
      default: translation_path.join(" ").humanize(capitalize: false),
    )
  end

  def add_format_errors(error)
    attribute, key = get_attribute_and_key_from_error(error)
    edition.errors.add(
      "details_#{key}",
      translate_error("invalid", attribute),
    )
  end

  def get_attribute_and_key_from_error(error)
    data_pointer = error["data_pointer"].delete_prefix("/")
    field_items = data_pointer.split("/")
    [field_items.last, key_with_optional_prefix(error, nil)]
  end

  def validate_with_schema(edition)
    DetailsValidator::SchemaValidationRunner.new(
      schema_body: edition.schema.body,
      details: edition.details,
    ).call
  end

  def key_with_optional_prefix(error, key)
    if error["data_pointer"].present?
      prefix = generate_prefix(error)
      [
        prefix,
        key,
      ].compact.join("_")
    else
      key
    end
  end

  def translate_error(type, attribute, **args)
    default = "activerecord.errors.models.edition.#{type}".to_sym
    I18n.t(
      "activerecord.errors.models.edition.attributes.#{attribute}.#{type}",
      attribute: attribute.humanize,
      default: [default],
      **args,
    )
  end

private

  def block_type_blank?
    @edition.errors.attribute_names.include?(:"document.block_type")
  end

  def generate_prefix(error)
    keys = error["data_pointer"].split("/")[1..]
    if error_is_for_embedded_object?(error)
      # Returns a reference to the data pointer with the key of the embedded object removed
      [
        keys[0],
        *keys[2..],
      ]
    else
      keys
    end
  end

  def error_is_for_embedded_object?(error)
    error["schema_pointer"]&.include?("patternProperties")
  end
end
