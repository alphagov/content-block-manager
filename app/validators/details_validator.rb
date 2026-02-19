class DetailsValidator < ActiveModel::Validator
  include CustomValidators

  attr_reader :edition

  def validate(edition)
    @edition = edition
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
      default: translation_path.join(" ").humanize,
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
    # Fetch the details and remove any blank fields (JSONSchema classes an empty string as valid,
    # unless a specific format has been specified)
    details = compact_nested(edition.details)
    schemer = JSONSchemer.schema(
      edition.schema.body,
      keywords: {
        "formatMinimum" => format_date_minimum(details),
      },
    )
    schemer.validate(details)
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

  def compact_nested(object)
    return object unless object.respond_to?(:compact_blank!)

    object.compact_blank!
    object.each { |o| compact_nested(o) }
    object
  end
end
