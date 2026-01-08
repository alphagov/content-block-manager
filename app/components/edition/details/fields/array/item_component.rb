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

  def label
    "#{field.label.singularize} #{index + 1}"
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

  def destroy_checkbox
    field_name = "#{field.name_attribute}[_destroy]"
    if can_be_deleted
      render("govuk_publishing_components/components/checkboxes", {
        name: field_name,
        items: [{ label: "Delete", value: "1" }],
        classes: "js-array-item-destroy",
      })
    else
      hidden_field_tag(field_name, 0)
    end
  end
end
