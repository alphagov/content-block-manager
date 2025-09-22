class Edition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper
  include TranslationHelper

  PARENT_CLASS = "edition".freeze

  def initialize(edition:, field:, schema:, value: nil, subschema: nil, **_args)
    @edition = edition
    @field = field
    @schema = schema
    @value = value || field.default_value
    @subschema = subschema
  end

private

  attr_reader :edition, :field, :schema, :subschema, :value

  def subschema_block_type
    @subschema_block_type ||= subschema&.block_type
  end

  def label
    optional = field.is_required? ? nil : optional_label
    "#{helpers.humanized_label(schema_name: schema.block_type, relative_key: field.name, root_object: subschema_block_type)}" \
    "#{optional}"
  end

  def optional_label
    " (optional)"
  end

  def name
    if subschema_block_type
      "edition[details][#{subschema_block_type}][#{field.name}]"
    else
      "edition[details][#{field.name}]"
    end
  end

  def id
    "#{PARENT_CLASS}_details_#{id_suffix}"
  end

  def error_items
    errors_for(edition.errors, "details_#{id_suffix}".to_sym)
  end

  def hint_text
    helpers.hint_text(schema:, subschema:, field:)
  end

  def id_suffix
    subschema_block_type ? "#{subschema_block_type}_#{field.name}" : field.name
  end
end
