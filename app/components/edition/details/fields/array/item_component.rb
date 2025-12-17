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
      component_for_field(item)
    end
  end

  def component_for_field(field)
    component_name = field.component_name
    component_class = "Edition::Details::Fields::#{component_name.camelize}Component".constantize
    args = component_args(field).merge(enum: field.enum_values, default: field.default_value)

    component_class.new(**args.compact)
  end

  def component_args(field)
    {
      edition:,
      field:,
      value: fetch_value(field),
      schema:,
      index:,
    }
  end

  def fetch_value(field)
    if value.is_a?(Hash) || value.is_a?(ActionController::Parameters)
      value.fetch(field.name, nil)
    else
      value
    end
  end
end
