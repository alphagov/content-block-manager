class Shared::EmbeddedObject::SummaryCardComponent < ViewComponent::Base
  include SummaryListHelper

  delegate :translated_value, to: :helpers

  delegate :document, to: :edition

  def initialize(edition:, object_type:, redirect_url: nil, test_id_prefix: nil)
    @edition = edition
    @object_type = object_type
    @redirect_url = redirect_url
    @test_id_prefix = test_id_prefix
  end

private

  attr_reader :edition, :object_type, :redirect_url, :test_id_prefix

  def title
    "#{object_type.titleize.singularize.capitalize} details".html_safe
  end

  def items
    schema.fields.index_with do |field|
      object[field.name]
    end
  end

  def rows
    first_class_items(items).map do |field, value|
      schema_field = schema.field(field.name)
      {
        key: schema_field.label,
        value: rendered_value_for_field(field.name, value),
      }
    end
  end

  def object
    @object ||= edition.details[object_type]
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
        href: helpers.edit_sole_embedded_object_edition_path(
          edition,
          object_type:,
          redirect_url:,
        ),
      },
    ]
  end

  def data_attributes
    test_id_prefix.present? ? { "test-id" => [test_id_prefix, object_type].join("_") } : {}
  end

  def rendered_value_for_field(field_name, _value)
    schema_field = schema.field(field_name)

    unless schema_field.schema.embeddable_as_block?
      raise ArgumentError, "Field '#{field_name}' must be embeddable"
    end

    embed_code = document.embed_code_for_field("#{object_type}/#{field_name}")
    edition.render(embed_code)
  end
end
