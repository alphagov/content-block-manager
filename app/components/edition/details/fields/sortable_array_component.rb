class Edition::Details::Fields::SortableArrayComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :field, :name, :id, :error_items, :edition, :schema, :subschema, :object_title, :indexes, to: :context

  def subschema_block_type
    @subschema_block_type ||= subschema&.block_type
  end

  def label
    field.title.singularize
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

  def component(index)
    Edition::Details::Fields::Array::SortableItemComponent.new(
      field:,
      edition:,
      schema:,
      value: value[index],
      index: index,
      parent_indexes: indexes,
    )
  end

  def wrapper_classes
    %W[
      app-c-content-block-manager-array-component
      app-c-content-block-manager-array-component--sortable
      app-c-content-block-manager-array-component--#{field.name}
    ]
  end

  def order_input(index)
    tag.input(
      class: "gem-c-input govuk-input govuk-input--width-2",
      id: "sortable_#{field.name}_#{index}_order",
      name: "#{field.name}[#{index}]order",
      value: index,
    )
  end

  def items
    components.map.with_index do |component, index|
      {
        fields: render(component),
        order_input: order_input(index),
      }
    end
  end
end
