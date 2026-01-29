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
    unordered_rows.sort_by { |row| row_ordering_rule(row) }
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
