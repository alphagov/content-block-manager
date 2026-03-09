class Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  include ContentBlockTools::Govspeak
  include SummaryListHelper

  delegate :translated_value, to: :helpers

  with_collection_parameter :items

  def initialize(items:, field:, items_counter: nil, edition: nil)
    @items = items
    @field = field
    @items_counter = items_counter
    @edition = edition
  end

private

  attr_reader :items, :field, :items_counter, :edition

  def title
    items_counter ? "#{field.title.singularize} #{items_counter + 1}" : field.title
  end

  def rows
    first_class_items(items).map do |field_name, value|
      nested_field = field.nested_field(field_name)
      {
        key: nested_field.label,
        value: nested_field_value(nested_field, value),
        data: { testid: nested_field.name },
      }
    end
  end

  def nested_field_value(nested_field, value)
    return rendered_block_for_nested_field(nested_field.name) if nested_field.schema.embeddable_as_block?

    render_govspeak_if_enabled_for_field(
      field: nested_field,
      value: translated_value(nested_field.name, value),
    )
  end

  def rendered_block_for_nested_field(nested_field_name)
    edition.render(
      edition.document.embed_code_for_field(
        "#{field.schema.id}/#{field.name}/#{nested_field_name}",
      ),
    )
  end

  def render_govspeak_if_enabled_for_field(field:, value:)
    return value unless field.govspeak_enabled?

    render_govspeak(value)
  end
end
