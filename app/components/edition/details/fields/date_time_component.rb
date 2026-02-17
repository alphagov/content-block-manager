class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  def initialize(context)
    @context = context
    @block_type = context.field.schema.id
    @field_name = context.field.name
    @prefix = "edition[details][#{@block_type}]"
  end

  attr_reader :context, :field_name, :prefix, :block_type
end
