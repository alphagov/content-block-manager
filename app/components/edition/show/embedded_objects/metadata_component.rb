class Edition::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  include TranslationHelper
  def initialize(items:, schema:)
    @items = items
    @schema = schema
  end

private

  attr_reader :items, :schema

  def rows
    ordering = MetadataRowOrderingRule.new(field_order:)
    unordered_rows.sort_by { |row| ordering.call(row) }
  end

  def unordered_rows
    items.map do |key, value|
      field = schema.field(key)
      {
        field: field.label,
        value: helpers.translated_value(key, value),
      }
    end
  end

  def field_order
    @schema.config["field_order"]
  end
end
