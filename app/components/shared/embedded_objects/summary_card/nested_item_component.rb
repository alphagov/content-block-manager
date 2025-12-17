class Shared::EmbeddedObjects::SummaryCard::NestedItemComponent < ViewComponent::Base
  include GovspeakHelper

  delegate :humanized_label, to: :helpers
  delegate :translated_value, to: :helpers

  with_collection_parameter :nested_items

  def initialize(nested_items:, object_key:, object_type:, title:, subschema:, root_schema_name:, nested_items_counter: nil)
    @nested_items = nested_items
    @object_key = object_key
    @object_type = object_type
    @title = title
    @subschema = subschema
    @root_schema_name = root_schema_name
    @nested_items_counter = nested_items_counter
  end

private

  attr_reader :nested_items, :object_key, :object_type, :subschema, :nested_items_counter, :root_schema_name

  def title
    if @nested_items_counter
      "#{@title} #{@nested_items_counter + 1}"
    else
      @title
    end
  end

  def rows
    nested_items.map do |field_name, value|
      {
        key: humanized_label(schema_name: root_schema_name, relative_key: field_name, root_object: "#{object_type}.#{object_key}"),
        value: render_govspeak_if_enabled_for_field(
          field_name: field_name,
          value: translated_value(field_name, value),
        ),
      }
    end
  end
end
