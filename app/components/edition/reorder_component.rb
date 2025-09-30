class Edition::ReorderComponent < ViewComponent::Base
  def initialize(edition:, order:)
    @edition = edition
    @order = order
  end

private

  attr_reader :edition, :order
end
