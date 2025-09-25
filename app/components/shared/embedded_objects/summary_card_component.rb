class Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  include SummaryListHelper

  delegate :translated_value, to: :helpers
  delegate :humanized_label, to: :helpers

  delegate :document, to: :edition

  with_collection_parameter :object_title

  def initialize(edition:, object_type:, object_title:, redirect_url: nil, test_id_prefix: nil)
    @edition = edition
    @object_type = object_type
    @object_title = object_title
    @redirect_url = redirect_url
    @test_id_prefix = test_id_prefix
  end

private

  attr_reader :edition, :object_type, :object_title, :redirect_url, :test_id_prefix

  def title
    "#{object_type.titleize.singularize.capitalize} details"
  end

  def nested_item_title(key)
    I18n.t("edition.titles.#{edition.schema.block_type}.#{schema.id}.#{key}", default: key.singularize.titleize)
  end

  def items
    schema.fields.map { |field|
      [field.name, object[field.name]]
    }.to_h
  end

  def rows
    first_class_items(items).map do |key, value|
      {
        field: key_to_title(key, object_type),
        value: translated_value(key, value),
        data: {
          testid: [object_title.parameterize, key].compact.join("_").underscore,
        },
      }
    end
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
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
    test_id_prefix.present? ? { "data-test-id" => [test_id_prefix, object_title].join("_") } : {}
  end
end
