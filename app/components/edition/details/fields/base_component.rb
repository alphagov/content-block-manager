class Edition::Details::Fields::BaseComponent < ViewComponent::Base
  include ErrorsHelper
  include TranslationHelper

  PARENT_CLASS = "edition".freeze

  def initialize(edition:, field:, schema:, value: nil, subschema: nil, index: nil, **_args)
    @edition = edition
    @field = field
    @schema = schema
    @value = value
    @subschema = subschema
    @index = index
  end

private

  attr_reader :edition, :field, :schema, :subschema, :value, :index

  def subschema_block_type
    @subschema_block_type ||= subschema&.block_type
  end

  def label
    optional = field.is_required? ? nil : optional_label
    "#{field.label}" \
    "#{optional}"
  end

  def optional_label
    " (optional)"
  end

  def name
    field.name_attribute
  end

  def id
    field.id_attribute(index)
  end

  def error_items
    errors_for(edition.errors, field.error_key(index).to_sym)
  end

  def hint_text
    field.hint
  end
end
