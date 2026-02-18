class FactCheck::EmbeddedMetadataDiffComponent < ViewComponent::Base
  include DiffHelper
  include TranslationHelper

  def initialize(schema:, items:)
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
        value: content_tag(
          :div,
          value["published"] ? render_diff(value["published"], value["new"]) : value["new"],
          class: "compare-editions",
        ),
      }
    end
  end

  def field_order
    @schema.config["field_order"]
  end
end
