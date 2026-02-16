class FactCheck::NestedBlocksWithSummaryDiffComponent < ViewComponent::Base
  include SummaryListHelper
  include DiffHelper

  def initialize(items:, object_type:, object_title:, block:)
    @items = items
    @object_type = object_type
    @object_title = object_title
    @block = block
    @document = block.document
  end

private

  attr_reader :items, :object_type, :object_title, :block, :document

  def attribute_rows(key_name = :key)
    first_class_items(items).flat_map do |key, value|
      {
        "#{key_name}": schema.field(key).label,
        value: content_for_row(value),
      }
    end
  end

  def content_for_row(value)
    content_tag(:div,
                render_diff(value["published"], value["new"]),
                class: "app-c-embedded-objects-blocks-component__content govspeak compare-editions")
  end

  def all_attributes_preamble
    I18n.t("embedded_object.all_attributes", object_name: object_name)
  end

  def nested_blocks
    nested_items(items).map { |key, items|
      if items.is_a?(Array)
        render FactCheck::NestedBlockDiffComponent.with_collection(
          items,
          field: schema.field(key),
        )
      else
        render FactCheck::NestedBlockDiffComponent.new(
          items:,
          field: schema.field(key),
        )
      end
    }.join.html_safe
  end

  def object_name
    object_type.singularize.humanize.downcase
  end

  def title
    "#{object_name} block".capitalize
  end

  def block_row
    {
      key: object_type.humanize.singularize.capitalize,
      value: content_for_block_row,
    }
  end

  def content_for_block_row
    new_content = render_block(block)

    content_tag(:div,
                block.published_block ? render_diff(render_block(block.published_block), new_content) : new_content,
                class: "app-c-embedded-objects-blocks-component__content govspeak compare-editions")
  end

  def render_block(block)
    return unless block.details.dig(object_type, object_title)

    block.render(document.embed_code_for_field("#{object_type}/#{object_title}"))
  end

  def schema
    @schema ||= document.schema.subschema(object_type)
  end
end
