class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  def initialize(context)
    @context = context
    @block_type = context.field.schema.id
    @field_name = context.field.name
    @prefix = "edition[details][#{@block_type}]"
  end

  def details
    @details ||= context.edition&.details&.dig(block_type, field_name) || {}
  end

  def date_value
    date = details["date"]
    @date_value ||= Date.parse(date) if date
  end

  def time_value
    time = details["time"]
    @time_value ||= time.split(":") if time
  end

  attr_reader :context, :field_name, :prefix, :block_type
end
