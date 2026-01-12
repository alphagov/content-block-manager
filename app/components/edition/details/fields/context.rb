class Edition::Details::Fields::Context
  include FormHelper
  include ErrorsHelper

  def initialize(edition:, field:, schema:, populate_with_defaults: false, subschema: nil, object_title: nil, index: nil, details: nil, parent_indexes: [])
    @edition = edition
    @field = field
    @schema = schema
    @populate_with_defaults = populate_with_defaults
    @subschema = subschema
    @object_title = object_title
    @index = index
    @details = details || edition.details
    @parent_indexes = parent_indexes
  end

  attr_reader :edition, :field, :schema, :populate_with_defaults, :subschema, :object_title, :index, :details, :parent_indexes

  def value
    value_for_field(details:, field:, populate_with_defaults:)
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
    field.id_attribute(indexes)
  end

  def error_items
    errors_for(edition.errors, field.error_key(indexes).to_sym)
  end

  def hint_text
    field.hint
  end

  def indexes
    [parent_indexes, index].flatten.compact
  end
end
