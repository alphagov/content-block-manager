class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @details = context.edition&.details&.dig(block_type, field_name) || {}
  end

private

  attr_reader :context, :field_name, :name_prefix, :block_type

  def field_name_for(part)
    lookup = %w[year month day hour minute]
    field = %w[year month day].include?(part) ? date_field : time_field
    "#{name_prefix}[#{field_name}][#{field.name}(#{lookup.index(part) + 1}i)]"
  end

  def date_time
    Edition::DateTimeParts.new(edition: context.edition, params:, block_type:, field_name:, date_field:, time_field:)
  end

  def date_field
    @date_field ||= context.field.nested_fields.find { |f| f.format.date? }
  end

  def time_field
    @time_field ||= context.field.nested_fields.find { |f| f.format.time? }
  end

  def error_items
    context.edition.errors[date_field.error_key].map do |error|
      { text: error }
    end
  end
end
