class FactCheck::EmbeddedBlockDiffComponent < ViewComponent::Base
  include SummaryListHelper
  include DiffHelper

  def initialize(items:, object_type:, object_title:, document:)
    @items = items
    @object_type = object_type
    @object_title = object_title
    @document = document
  end

private

  attr_reader :items, :object_type, :object_title, :document

  def title
    "#{object_type.singularize.humanize.downcase} block".capitalize
  end

  def rows
    first_class_items(items).flat_map do |key, value|
      {
        key: schema.field(key).label,
        value: content_for_row(value),
      }
    end
  end

  def content_for_row(value)
    if value["published"]
      content_tag(:div, render_diff(value["published"], value["new"]), class: "compare-editions")
    else
      value["new"]
    end
  end

  def schema
    @schema ||= document.schema.subschema(object_type)
  end

  def get_published_item(*args)
    items_published&.dig(*args) || {}
  end
end
