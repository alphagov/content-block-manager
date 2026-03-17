class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  include DateTimeHelper

  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @details = context.edition&.details&.dig(block_type, field_name) || {}
  end

private

  attr_reader :context, :field_name, :name_prefix, :block_type, :details

  def field_name_for(part)
    date_time_field_name(name_prefix:, field_name:, nested_fields:, part:)
  end

  def date_field
    @date_field ||= get_date_field(nested_fields)
  end

  def time_field
    @time_field ||= get_time_field(nested_fields)
  end

  def nested_fields
    @nested_fields ||= context.field.nested_fields
  end

  def date_time
    @date_time ||= begin
      date = details.fetch(date_field.name, "")
      time = details.fetch(time_field.name, "")
      Time.zone.iso8601("#{date}T#{time}")
    rescue ArgumentError
      nil
    end
  end

  def param_value(key)
    params.dig(:edition, :details, block_type, field_name, key)
  end

  # Attempt to fetch the hour/minute values from the params, otherwise fall back to the date_time object. As underlying
  # component expects an integer, we need to convert the value to an integer.
  def hour_value
    value = param_value("#{time_field.name}(4i)") || date_time&.hour
    value.to_i
  end

  def minute_value
    value = param_value("#{time_field.name}(5i)") || date_time&.min
    value.to_i
  end
end
