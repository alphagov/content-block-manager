class Edition::Show::EmbeddedObjects::MetadataComponent < ViewComponent::Base
  include TranslationHelper
  def initialize(items:, schema:)
    @items = items
    @schema = schema
  end

private

  attr_reader :items, :schema

  def rows
    ordering = MetadataRowOrderingRule.new(field_order: schema.field_order)
    unordered_rows.sort_by { |row| ordering.call(row) }
  end

  def unordered_rows
    items.map do |key, value|
      field = schema.field(key)
      {
        field: field.label,
        value: value,
      }
    end
  end
end
