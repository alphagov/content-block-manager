class Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  include ContentBlockTools::Govspeak
  include SummaryListHelper

  delegate :translated_value, to: :helpers

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
    first_class_items(items).map do |field_name, value|
      nested_field = field.nested_field(field_name)
      {
        key: nested_field.label,
        value: render_govspeak_if_enabled_for_field(
          field: nested_field,
          value: translated_value(field_name, value),
        ),
      }
    end
  end

  def render_govspeak_if_enabled_for_field(field:, value:)
    return value unless field.govspeak_enabled?

    render_govspeak(value)
  end
end
