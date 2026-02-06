class FactCheck::NestedBlockDiffComponent < ViewComponent::Base
  include ContentBlockTools::Govspeak
  include SummaryListHelper
  include DiffHelper

  delegate :translated_value, to: :helpers

  with_collection_parameter :paired_content

  def initialize(paired_content:, field:, edition:, paired_content_counter: nil)
    @paired_content = paired_content
    @items = paired_content.content_b
    @items_published = paired_content.content_a
    @field = field
    @edition = edition
    @document = edition.document
    @items_counter = paired_content_counter
  end

private

  attr_reader :items, :items_published, :field, :document, :edition, :items_counter, :paired_content

  def title
    items_counter ? "#{field.title.singularize} #{items_counter + 1}" : field.title
  end

  def rows
    first_class_items_published = first_class_items(items_published)
    first_class_items(items).map { |field_name, value|
      nested_field = field.nested_field(field_name)
      next if nested_field.hidden?

      {
        key: nested_field.label,
        value: value_for_row(nested_field, value, first_class_items_published[field_name] || ""),
      }
    }.compact
  end

  def value_for_row(field, value, value_published)
    content_tag(:div,
                render_govspeak_if_enabled_for_field(
                  field:,
                  value: render_diff(value_published, translated_value(field.name, value))),
                class: "app-c-embedded-objects-blocks-component__content govspeak compare-editions")
  end

  def render_govspeak_if_enabled_for_field(field:, value:)
    return value unless field.govspeak_enabled?

    render_govspeak(value)
  end
end
