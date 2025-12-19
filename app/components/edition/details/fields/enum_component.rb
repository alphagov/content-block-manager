class Edition::Details::Fields::EnumComponent < Edition::Details::Fields::BaseComponent
  def options
    options = [
      {
        text: blank_option,
        value: "",
        selected: selected?(blank_option),
      },
    ]

    enum.each do |item|
      options.push({
        text: item,
        value: item,
        selected: selected?(item),
      })
    end

    options
  end

private

  def enum
    field.enum_values
  end

  def error_message
    error_items&.first&.fetch(:text)
  end

  def default_value
    field.default_value || ""
  end

  def selected?(item)
    item == (value.presence || default_value)
  end

  def blank_option
    default_value.empty? ? "" : nil
  end
end
