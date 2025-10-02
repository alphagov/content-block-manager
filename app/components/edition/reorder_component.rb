class Edition::ReorderComponent < ViewComponent::Base
  def initialize(edition:, order:, redirect_path:)
    @edition = edition
    @order = order
    @redirect_path = redirect_path
  end

private

  attr_reader :edition, :order, :redirect_path

  def item_keys
    items_missing_from_order = edition.default_order - order
    order + items_missing_from_order
  end

  def move_path(position, item, direction)
    updated_order = order.dup
    new_position = direction == :up ? position - 1 : position + 1
    updated_order.insert(
      new_position,
      updated_order.delete(item),
    )
    order_edit_edition_path(edition, order: updated_order, redirect_path:)
  end
end
