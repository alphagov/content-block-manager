class Edition::Show::EmbeddedObjects::BlocksComponent < ViewComponent::Base
  include EmbedCodeHelper
  include SummaryListHelper

  def initialize(items:, schema_name:, object_type:, object_title:, edition:)
    @items = items
    @schema_name = schema_name
    @object_type = object_type
    @object_title = object_title
    @edition = edition
    @document = edition.document
  end

private

  attr_reader :items, :schema_name, :object_type, :object_title, :edition, :document

  def component_classes
    [
      "app-c-embedded-objects-blocks-component",
      ("app-c-embedded-objects-blocks-component--with-block" if schema.embeddable_as_block?),
    ].compact.join(" ")
  end

  def summary_card_rows
    if schema.embeddable_as_block?
      [block_row]
    else
      attribute_rows
    end
  end

  def attribute_rows(key_name = :key)
    first_class_items(items).flat_map do |key, value|
      build_rows_for_field(key_name, key, value)
    end
  end

  def build_rows_for_field(key_name, key, value)
    is_list = value.is_a?(Array)

    Array(value).each_with_index.map do |item, index|
      field = schema.field(key)
      suffix = is_list ? "#{key}/#{index}" : key
      label = is_list ? "#{field.label.singularize} #{index + 1}" : field.label

      {
        "#{key_name}": label,
        value: content_for_row(suffix, item),
        data: data_attributes_for_row(suffix),
      }
    end
  end

  def block_title(key)
    schema.field(key).title
  end

  def nested_blocks
    blocks = []

    nested_items(items).each do |key, items|
      if items.is_a?(Array)
        items.each_with_index do |nested_items, index|
          blocks << {
            title: "#{block_title(key).singularize} #{index + 1}",
            rows: rows_for_nested_items(nested_items, key, index),
          }
        end
      else
        blocks << {
          title: block_title(key),
          rows: rows_for_nested_items(items, key, nil),
        }
      end
    end

    blocks
  end

  def rows_for_nested_items(items, nested_name, index)
    visible_fields(items, nested_name).map do |key, value|
      field = schema.field(nested_name).nested_field(key)
      {
        key: field.label,
        value: content_for_row(embed_code_identifier(nested_name, index, key), translated_value(key, value)),
        data: data_attributes_for_row(embed_code_identifier(nested_name, index, key)),
      }
    end
  end

  def visible_fields(fields, nested_name)
    fields.reject do |field_name, _v|
      parent_field = schema.field(nested_name)
      field = parent_field.nested_field(field_name)
      field.hidden?
    end
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
      data: data_attributes_for_block_row,
    }
  end

  def content_for_row(key, value)
    content = content_tag(:p, value, class: "app-c-embedded-objects-blocks-component__content govspeak")
    content << content_tag(:p, document.embed_code_for_field("#{object_type}/#{object_title}/#{key}"), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def data_attributes_for_row(key)
    {
      testid: (object_title.parameterize + "_#{key}").underscore,
      **copy_embed_code_data_attributes("#{object_type}/#{object_title}/#{key}", document),
    }
  end

  def content_for_block_row
    content = content_tag(:div,
                          edition.render(document.embed_code_for_field("#{object_type}/#{object_title}")),
                          class: "app-c-embedded-objects-blocks-component__content govspeak")
    content << content_tag(:p, document.embed_code_for_field("#{object_type}/#{object_title}"), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def data_attributes_for_block_row
    {
      testid: object_title.parameterize.underscore,
      **copy_embed_code_data_attributes("#{object_type}/#{object_title}", document),
    }
  end

  def schema
    @schema ||= document.schema.subschema(object_type)
  end

  def embed_code_identifier(*arr)
    arr.compact.join("/")
  end
end
