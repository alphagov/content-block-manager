class DetailsValidator::SchemaValidationRunner
  attr_reader :schema_body, :details

  def initialize(schema_body:, details:)
    @schema_body = schema_body
    @details = details
  end

  def call
    schemer.validate(compacted_details)
  end

private

  def schemer
    JSONSchemer.schema(
      schema_body,
      keywords: {
        "formatMinimum" => format_date_minimum(compacted_details),
      },
      formats: {
        "time" => ->(instance, _format) { valid_time?(instance) },
        "datetime" => ->(instance, _format) { valid_datetime?(instance) },
      },
    )
  end

  # JSON schema accepts empty strings as valid for many fields. Compact blanks before validating.
  def compacted_details
    @compacted_details ||= compact_nested(details)
  end

  def compact_nested(object)
    return object unless object.respond_to?(:compact_blank!)

    object.compact_blank!
    object.each { |item| compact_nested(item) }
    object
  end

  def format_date_minimum(body)
    proc do |instance, schema, _instance_location|
      min_str = schema.fetch("formatMinimum")

      if min_str.is_a?(Hash)
        lookup = min_str["$ref"].delete_prefix("#").split("/").compact_blank
        min_str = body.stringify_keys.dig(*lookup)
      end

      inst = Date.iso8601(instance)
      min  = Date.iso8601(min_str)

      inst >= min ? true : "formatMinimum"
    rescue Date::Error
      true # If the date is invalid, this will have been caught by the date validator, so return true
    end
  end

  def valid_time?(instance)
    instance.match?(/^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/)
  end

  def valid_datetime?(instance)
    Time.iso8601(instance)
  rescue StandardError
    false
  end
end
