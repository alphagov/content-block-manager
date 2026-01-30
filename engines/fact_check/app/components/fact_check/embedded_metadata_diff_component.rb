class FactCheck::EmbeddedMetadataDiffComponent < ViewComponent::Base
  include DiffHelper
  include TranslationHelper

  def initialize(schema:, items:, items_published: {})
    @items = items
    @items_published = items_published
    @schema = schema
  end

private

  attr_reader :items, :items_published, :schema

  def rows
    ordering = MetadataRowOrderingRule.new(field_order:)
    unordered_rows.sort_by { |row| ordering.call(row) }
  end

  def unordered_rows
    items.map do |key, value|
      field = schema.field(key)
      {
        field: field.label,
        value: content_tag(
          :div,
          items_published ? render_diff(items_published[key], value) : value,
          class: "compare-editions",
        ),
      }
    end
  end

  def field_order
    @schema.config["field_order"]
  end
end
