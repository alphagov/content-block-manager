class Edition::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  include TranslationHelper
  def initialize(items:, object_type:, schema_name:, schema:)
    @items = items
    @object_type = object_type
    @schema_name = schema_name
    @schema = schema
  end

private

  attr_reader :items, :schema_name, :object_type, :object_title

  def rows
    unordered_rows.sort_by { |row| row_ordering_rule(row) }
  end

  def unordered_rows
    items.map do |key, value|
      {
        field: helpers.humanized_label(schema_name:, relative_key: key, root_object: object_type),
        value: helpers.translated_value(key, value),
      }
    end
  end

  def row_ordering_rule(row)
    field = row.fetch(:field).is_a?(String) ? row.fetch(:field).downcase : row.fetch(:field)

    if field_order
      # If a field order is found in the config, order by the index. If a field is not found, put it to the end
      field_order.index(field) || Float::INFINITY
    else
      # By default, order with title first
      field == "title" ? 0 : 1
    end
  end

  def field_order
    @schema.config["field_order"]
  end
end
