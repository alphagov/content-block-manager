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
    []
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

  def wrapper_attributes
    {
      "class" => "govuk-summary-card",
      **data_attributes,
    }
  end

  def data_attributes
    test_id_prefix.present? ? { "test-id" => [test_id_prefix, object_type].join("_") } : {}
  end
end
