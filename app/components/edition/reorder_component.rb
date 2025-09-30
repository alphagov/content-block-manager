class Edition::ReorderComponent < ViewComponent::Base
  def initialize(edition:, order:)
    @edition = edition
    @order = order
  end

private

  attr_reader :edition, :order

  def move_path(position, item, direction)
    updated_order = order.dup
    new_position = direction == :up ? position - 1 : position + 1
    updated_order.insert(
      new_position,
      updated_order.delete(item),
    )
    order_edit_edition_path(edition, order: order_dup)
  end
end
