module DateAndTime
  class FieldValues
    def initialize(year:, month:, day:, hour: nil, minute: nil)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @minute = minute
      @year_int = parse_integer(year)
      @month_int = parse_integer(month)
      @day_int = parse_integer(day)
      @hour_int = hour.present? ? hour.to_i : 0
      @minute_int = minute.present? ? minute.to_i : 0
    end

    attr_reader :year, :month, :day, :hour, :minute,
                :year_int, :month_int, :day_int, :hour_int, :minute_int

    def self.from_params(params, field_name)
      new(
        year: params["#{field_name}(1i)"],
        month: params["#{field_name}(2i)"],
        day: params["#{field_name}(3i)"],
        hour: params["#{field_name}(4i)"],
        minute: params["#{field_name}(5i)"],
      )
    end

    def parse_integer(value)
      return nil if value.blank?

      Integer(value)
    rescue ArgumentError
      nil
    end

    def all_date_fields_blank?
      year.blank? && month.blank? && day.blank?
    end

    def any_date_field_unparseable?
      year_int.nil? || month_int.nil? || day_int.nil?
    end

    def negative_day_or_month_provided?
      month_int <= 0 || day_int <= 0
    end
  end
end
