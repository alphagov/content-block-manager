class Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  include ContentBlockTools::Govspeak

  delegate :translated_value, to: :helpers

  with_collection_parameter :nested_items

  def initialize(nested_items:, field:, nested_items_counter: nil)
    @nested_items = nested_items
    @field = field
    @nested_items_counter = nested_items_counter
  end

private

  attr_reader :nested_items, :field, :nested_items_counter

  def title
    nested_items_counter ? "#{field.title.singularize} #{nested_items_counter + 1}" : field.title
  end

  def rows
    nested_items.map do |field_name, value|
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
