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
    if value.count.positive?
      value.count
    else
      field.is_required? ? 1 : 0
    end
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
    "array-component-#{edition.id}-#{context.id}"
  end

  def adding_another?
    params[:add_another] == field.name
  end

  def button_text
    if number_of_items.positive? || adding_another?
      I18n.t("buttons.add_another", item: label.downcase)
    else
      I18n.t("buttons.add", item: label.downcase)
    end
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
    if index.zero? && field.is_required?
      false
    else
      immutability_checker&.can_be_deleted?(index)
    end
  end

  def immutability_checker
    @immutability_checker ||= EmbeddedObjectImmutabilityCheck.new(
      edition: edition.document.latest_published_edition,
      field_reference: [subschema_block_type, object_title, field.name].compact,
    )
  end
end
