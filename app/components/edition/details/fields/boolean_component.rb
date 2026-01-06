class Edition::Details::Fields::BooleanComponent < ViewComponent::Base
  def initialize(context)
    @context = context
  end

private

  attr_reader :context

  delegate :label, :name, :id, :value, :error_items, :hint_text, to: :context

  def items
    [
      {
        value: true,
        label:,
        checked: value.present? ? ActiveModel::Type::Boolean.new.cast(value) : false,
      },
    ]
  end
end
