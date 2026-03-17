module DateTimeHelper
  DATE_PARTS = %w[year month day].freeze

  PART_INDEX = {
    "year" => 1,
    "month" => 2,
    "day" => 3,
    "hour" => 4,
    "minute" => 5,
  }.freeze

  def date_time_field_name(name_prefix:, field_name:, nested_fields:, part:)
    key = part.to_s
    index = PART_INDEX.fetch(key) { raise ArgumentError, "Unknown date/time part: #{key}" }
    nested_field = is_date?(key) ? get_date_field(nested_fields) : get_time_field(nested_fields)

    "#{name_prefix}[#{field_name}][#{nested_field.name}(#{index}i)]"
  end

  def is_date?(key)
    DATE_PARTS.include?(key)
  end

  def get_date_field(nested_fields)
    nested_fields.find { |field| field.format.date? } ||
      raise(ArgumentError, "No nested date field found")
  end

  def get_time_field(nested_fields)
    nested_fields.find { |field| field.format.time? } ||
      raise(ArgumentError, "No nested time field found")
  end
end
