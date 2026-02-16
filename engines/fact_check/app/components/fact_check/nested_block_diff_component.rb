class FactCheck::NestedBlockDiffComponent < ViewComponent::Base
  include SummaryListHelper
  include DiffHelper

  with_collection_parameter :items

  def initialize(items:, field:, items_counter: nil)
    @items = items
    @field = field
    @items_counter = items_counter
  end

private

  attr_reader :items, :field, :items_counter

  def title
    items_counter ? "#{field.title.singularize} #{items_counter + 1}" : field.title
  end

  def rows
    first_class_items(items).map { |field_name, value|
      nested_field = field.nested_field(field_name)
      next if nested_field.hidden?

      {
        key: nested_field.label,
        value: value_for_row(value),
      }
    }.compact
  end

  def value_for_row(value)
    content_tag(:div,
                render_diff(value["published"], value["new"]),
                class: "app-c-embedded-objects-blocks-component__content compare-editions")
  end
end
