class Edition::Details::Fields::ObjectComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :field, :value, :label, :edition, :schema, :populate_with_defaults, :indexes, to: :context

  def show_field
    @show_field ||= field.show_field
  end

  def conditionally_revealed?
    field.show_field.present?
  end

  def nested_fields
    conditionally_revealed? ? field.nested_fields.reject { |f| f.name == show_field.name } : field.nested_fields
  end

  def show_field_context
    @show_field_context ||= context_for(show_field)
  end

  def context_for(nested_field)
    Edition::Details::Fields::Context.new(
      edition:,
      field: nested_field,
      schema:,
      populate_with_defaults:,
      details: value,
      parent_indexes: indexes,
    )
  end
end
