class Edition::Details::Fields::CountryComponent < Edition::Details::Fields::EnumComponent
  BLANK_OPTION = "United Kingdom".freeze

private

  def enum
    @enum ||= WorldLocation.countries.map(&:name).excluding(blank_option)
  end

  def blank_option
    BLANK_OPTION
  end
end
