class Edition::Details::Fields::CountryComponent < Edition::Details::Fields::EnumComponent
  BLANK_OPTION = "United Kingdom".freeze

  def initialize(**args)
    countries = WorldLocation.countries.map(&:name)
    super(**args.merge(enum: countries))
  end

private

  def enum
    @enum.excluding(blank_option)
  end

  def blank_option
    BLANK_OPTION
  end
end
