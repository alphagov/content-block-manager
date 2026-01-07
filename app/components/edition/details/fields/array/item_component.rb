class Edition::Details::Fields::Array::ItemComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(field:, edition:, schema:, value:, index:, can_be_deleted:, hints:)
    @field = field
    @edition = edition
    @schema = schema
    @value = value
    @index = index
    @can_be_deleted = can_be_deleted
    @hints = hints || {}
  end

private

  attr_reader :field, :edition, :schema, :value, :index, :can_be_deleted, :hints

  def wrapper_classes
    [
      "app-c-content-block-manager-array-item-component",
      ("app-c-content-block-manager-array-item-component--immutable" unless can_be_deleted),
    ].join(" ")
  end

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
    )
  end
end
