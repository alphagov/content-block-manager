class Edition::Details::Fields::BooleanComponent < Edition::Details::Fields::BaseComponent
private

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
