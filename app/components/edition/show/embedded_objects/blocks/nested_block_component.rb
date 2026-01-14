class Edition::Show::EmbeddedObjects::Blocks::NestedBlockComponent < ViewComponent::Base
  include ContentBlockTools::Govspeak
  include EmbedCodeHelper
  include SummaryListHelper

  delegate :translated_value, to: :helpers

  with_collection_parameter :items

  def initialize(items:, field:, document:, embed_code_prefix:, items_counter: nil)
    @items = items
    @field = field
    @document = document
    @embed_code_prefix = embed_code_prefix
    @items_counter = items_counter
  end

private

  attr_reader :items, :field, :document, :embed_code_prefix, :items_counter

  def title
    items_counter ? "#{field.title.singularize} #{items_counter + 1}" : field.title
  end

  def rows
    first_class_items(items).map { |field_name, value|
      nested_field = field.nested_field(field_name)
      next if nested_field.hidden?

      {
        key: nested_field.label,
        value: value_for_row(nested_field, value),
        data: data_attributes_for_row(nested_field),
      }
    }.compact
  end

  def value_for_row(field, value)
    content = content_tag(:p, render_govspeak_if_enabled_for_field(
                                field:,
                                value: translated_value(field.name, value),
                              ), class: "app-c-embedded-objects-blocks-component__content govspeak")
    content << content_tag(:p, document.embed_code_for_field(embed_code_identifier(embed_code_prefix, items_counter, field.name)), class: "app-c-embedded-objects-blocks-component__embed-code")
    content
  end

  def render_govspeak_if_enabled_for_field(field:, value:)
    return value unless field.govspeak_enabled?

    render_govspeak(value)
  end

  def data_attributes_for_row(field)
    embed_code = embed_code_identifier(embed_code_prefix, items_counter, field.name)
    {
      testid: embed_code.underscore,
      **copy_embed_code_data_attributes(embed_code, document),
    }
  end

  def embed_code_identifier(*arr)
    arr.compact.join("/")
  end
end
