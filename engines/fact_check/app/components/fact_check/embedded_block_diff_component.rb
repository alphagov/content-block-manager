class FactCheck::EmbeddedBlockDiffComponent < ViewComponent::Base
  include SummaryListHelper
  include DiffHelper

  def initialize(items:, items_published:, object_type:, object_title:, document:)
    @items = items
    @items_published = items_published
    @object_type = object_type
    @object_title = object_title
    @document = document
  end

private

  attr_reader :items, :items_published, :object_type, :object_title, :document

  def title
    "#{object_type.singularize.humanize.downcase} block".capitalize
  end

  def rows
    summary_card_rows(items).map.with_index do |item, index|
      {
        **item,
        value: content_tag(:div, row_content(item, index), class: "compare-editions"),
      }
    end
  end

  def row_content(item, index)
    return item[:value] unless items_published

    published = summary_card_rows(items_published)[index][:value]
    render_diff(published, item[:value])
  end

  def summary_card_rows(block_items, key_name = :key)
    first_class_items(block_items).flat_map do |key, value|
      build_row_for_field(key_name, key, value)
    end
  end

  def build_row_for_field(key_name, key, value)
    {
      "#{key_name}": schema.field(key).label,
      value: content_for_row(key, value),
    }
  end

  def content_for_row(_key, value)
    content_tag(:p, value, class: "app-c-embedded-objects-blocks-component__content govspeak")
  end

  def schema
    @schema ||= document.schema.subschema(object_type)
  end

  def get_published_item(*args)
    items_published&.dig(*args) || {}
  end
end
