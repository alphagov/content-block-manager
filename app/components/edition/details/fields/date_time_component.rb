class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  include DateTimeHelper

  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @details = context.edition&.details&.dig(block_type, field_name) || {}
    @date_time = DateTimeConverter.from_strings(date: @details["date"], time: @details["time"]).date_time
  end

private

  attr_reader :context, :field_name, :name_prefix, :block_type, :date_time

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
end
