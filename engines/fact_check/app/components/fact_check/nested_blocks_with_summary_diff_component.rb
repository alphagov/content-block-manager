class FactCheck::NestedBlocksWithSummaryDiffComponent < ViewComponent::Base
  include SummaryListHelper
  include DiffHelper

  def initialize(items:, items_published:, object_type:, object_title:, edition:)
    @items = items
    @items_published = items_published
    @object_type = object_type
    @object_title = object_title
    @edition = edition
    @document = edition.document
  end

private

  attr_reader :items, :items_published, :object_type, :object_title, :edition, :document

  def summary_card_rows
    [block_row]
  end

  def attribute_rows(key_name = :key)
    first_class_items_published = first_class_items(items_published)
    first_class_items(items).flat_map do |key, value|
      build_rows_for_field(key_name, key, value, first_class_items_published[key])
    end
  end

  def build_rows_for_field(key_name, key, value, value_published)
    is_list = value.is_a?(Array)

    Array(value).each_with_index.map do |item, index|
      field = schema.field(key)
      suffix = is_list ? "#{key}/#{index}" : key
      label = is_list ? "#{field.label.singularize} #{index + 1}" : field.label

      {
        "#{key_name}": label,
        value: content_for_row(suffix, value_published ? render_diff(Array(value_published)[index], item) : item),
      }
    end
  end

  def all_attributes_preamble
    I18n.t("embedded_object.all_attributes", object_name: object_name)
  end

  def nested_blocks
    nested_items_published = nested_items(items_published)
    nested_items(items).map { |key, items|
      if items.is_a?(Array)
        render FactCheck::NestedBlockDiffComponent.with_collection(
          PairedContent.new(nested_items_published[key], items),
          field: schema.field(key),
          edition:,
        )
      else
        render FactCheck::NestedBlockDiffComponent.new(
          paired_content: PairedContent.new(nested_items_published[key], items),
          field: schema.field(key),
          edition:,
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
    published_content = edition.published_block.details.dig(object_type, object_title) ? edition.published_block.render(document.embed_code_for_field("#{object_type}/#{object_title}")) : ""
    new_content = edition.render(document.embed_code_for_field("#{object_type}/#{object_title}"))

    content_tag(:div,
                render_diff(published_content, new_content),
                class: "app-c-embedded-objects-blocks-component__content govspeak compare-editions")
  end

  def content_for_row(_key, value)
    content_tag(:div, value, class: "app-c-embedded-objects-blocks-component__content govspeak compare-editions")
  end

  def data_attributes_for_block_row
    {
      testid: object_title.parameterize.underscore,
    }
  end

  def schema
    @schema ||= document.schema.subschema(object_type)
  end
end
