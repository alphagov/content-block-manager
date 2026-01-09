class Edition::Details::Fields::ArrayComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :field, :name, :id, :error_items, :hint_text, :edition, :schema, :subschema, :object_title, :indexes, to: :context

  def subschema_block_type
    @subschema_block_type ||= subschema&.block_type
  end

  def label
    field.label.singularize
  end

  def value
    context.value || []
  end

  def number_of_items
    value.count.positive? ? value.count : 1
  end

  def components
    number_of_items.times.map do |index|
      component(index)
    end
  end

  def empty_component
    component(number_of_items)
  end

  def frame_id
    "array-component-#{edition.id}-#{field.name}"
  end

  def component(index)
    Edition::Details::Fields::Array::ItemComponent.new(
      field:,
      edition:,
      schema:,
      value: value[index],
      index: index,
      can_be_deleted: can_be_deleted?(index),
      hints: hint_text,
      parent_indexes: indexes,
    )
  end

  def can_be_deleted?(index)
    immutability_checker&.can_be_deleted?(index)
  end

  def immutability_checker
    @immutability_checker ||= EmbeddedObjectImmutabilityCheck.new(
      edition: edition.document.latest_published_edition,
      field_reference: [subschema_block_type, object_title, field.name].compact,
    )
  end
end
