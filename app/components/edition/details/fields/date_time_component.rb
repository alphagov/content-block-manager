class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @details = context.edition&.details&.dig(block_type, field_name) || {}
    @date_time = DateTimeConverter.from_strings(date: @details["date"], time: @details["time"]).date_time
  end

  attr_reader :context, :field_name, :name_prefix, :block_type, :date_time
end
