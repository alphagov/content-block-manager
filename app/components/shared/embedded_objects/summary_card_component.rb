class Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  include SummaryListHelper

  delegate :translated_value, to: :helpers

  delegate :document, to: :edition

  with_collection_parameter :object_title

  def initialize(edition:, object_type:, object_title:, redirect_url: nil, test_id_prefix: nil, object_title_counter: 0)
    @edition = edition
    @object_type = object_type
    @object_title = object_title
    @redirect_url = redirect_url
    @test_id_prefix = test_id_prefix
    @counter = object_title_counter + 1
  end

private

  attr_reader :edition, :object_type, :object_title, :redirect_url, :test_id_prefix, :counter

  def title
    "#{object_type.titleize.singularize.capitalize} details <span class=\"govuk-visually-hidden\">#{counter}</span>".html_safe
  end

  def items
    binding.pry
    schema.fields.index_with do |field|
      object[field.name]
    end
  end

  def rows
    first_class_items(items).flat_map do |field, value|
      build_rows_for_field(field, value)
    end
  end

  def build_rows_for_field(field, value)
    is_list = value.is_a?(Array)

    Array(value).each_with_index.map do |item, index|
      suffix = is_list ? "#{field.name}/#{index}" : field.name
      label = is_list ? "#{field.label.singularize} #{index + 1}" : field.label

      {
        key: label,
        value: translated_value(field.name, item),
        data: { testid: testid_for(suffix) },
      }
    end
  end

  def testid_for(key)
    [object_title.parameterize, key].compact.join("_").underscore
  end

  def block_display_fields
    @block_display_fields ||= schema.block_display_fields
  end

  def object
    @object ||= edition.details.dig(object_type, object_title)
  end

  def schema
    @schema ||= root_schema.subschema(object_type)
  end

  def root_schema
    @root_schema ||= edition.document.schema
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.edit_embedded_object_edition_path(
          edition,
          object_type:,
          object_title:,
          redirect_url:,
        ),
      },
    ]
  end

  def wrapper_attributes
    {
      "class" => "govuk-summary-card",
      **data_attributes,
    }
  end

  def data_attributes
    test_id_prefix.present? ? { "test-id" => [test_id_prefix, object_title].join("_") } : {}
  end
end
