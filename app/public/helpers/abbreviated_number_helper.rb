module AbbreviatedNumberHelper
  include ActionView::Helpers::NumberHelper

  ABBREVIATED_UNITS = { thousand: "k", million: "m", billion: "b" }.freeze

  def abbreviated_number(number)
    number_to_human(number, format: "%n%u", precision: 3, significant: true, units: ABBREVIATED_UNITS)
  end
end
