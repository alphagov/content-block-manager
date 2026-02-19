class DetailsValidator < ActiveModel::Validator
  include CustomValidators

  attr_reader :edition

  def validate(edition)
    @edition = edition
    errors = validate_with_schema(edition)
    errors.each do |e|
      if e["type"] == "required"
        add_blank_errors(e)
      elsif %w[format pattern formatMinimum].include?(e["type"])
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

  def add_format_errors(error)
    data_pointer = error["data_pointer"].delete_prefix("/")
    field_items = data_pointer.split("/")
    attribute = field_items.last
    key = key_with_optional_prefix(error, nil)
    edition.errors.add(
      "details_#{key}",
      translate_error("invalid", attribute),
    )
  end

  def validate_with_schema(edition)
    # Fetch the details and remove any blank fields (JSONSchema classes an empty string as valid,
    # unless a specific format has been specified)
    details = compact_nested(edition.details)
    schemer = JSONSchemer.schema(
      edition.schema.body,
      keywords: {
        "formatMinimum" => format_date_minimum,
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

  def translate_error(type, attribute)
    default = "activerecord.errors.models.edition.#{type}".to_sym
    I18n.t(
      "activerecord.errors.models.edition.attributes.#{attribute}.#{type}",
      attribute: attribute.humanize,
      default: [default],
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
