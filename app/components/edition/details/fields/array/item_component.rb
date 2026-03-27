class Edition::Details::Fields::Array::ItemComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(field:, edition:, schema:, value:, index:, parent_indexes:)
    @field = field
    @edition = edition
    @schema = schema
    @value = value
    @index = index
    @parent_indexes = parent_indexes
  end

private

  attr_reader :field, :edition, :schema, :value, :index, :parent_indexes

  def components
    fields = field.nested_fields || [field]

    fields.map do |item|
      helpers.component_for_field(item, context(item))
    end
  end

  def context(field)
    Edition::Details::Fields::Context.new(
      edition:,
      field:,
      schema:,
      index:,
      details: value,
      parent_indexes:,
    )
  end
end
