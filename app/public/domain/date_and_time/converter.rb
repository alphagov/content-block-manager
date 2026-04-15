module DateAndTime
  class Converter
    class UnparseableDateError < StandardError; end

    attr_reader :date_time, :errors, :raw_params

    class << self
      def from_strings(date:, time:)
        new(Time.zone.parse("#{date} #{time}"))
      end

      def from_params(params:, field_name:)
        new(nil, params:, field_name:)
      end
    end

    def initialize(date_time, params: nil, field_name: nil)
      @errors = []
      @raw_params = params

      if params && field_name
        parse_from_params(params, field_name)
      else
        @date_time = date_time
      end
    end

    def valid?
      errors.empty?
    end

    def to_iso8601
      date_time&.iso8601
    end

  private

    def parse_from_params(params, field_name)
      values = DateAndTime::FieldValues.from_params(params, field_name)

      return add_error(:date_blank) if values.all_date_fields_blank?
      return add_error(:date_invalid) if values.any_date_field_unparseable?
      return add_error(:date_invalid) if values.negative_day_or_month_provided?

      ensure_date_is_valid(values)
      @date_time = build_datetime(values)
    rescue UnparseableDateError
      add_error(:date_invalid)
    end

    def ensure_date_is_valid(values)
      Date.new(values.year_int, values.month_int, values.day_int)
    rescue ArgumentError
      raise UnparseableDateError
    end

    def build_datetime(values)
      Time.zone.local(
        values.year_int,
        values.month_int,
        values.day_int,
        values.hour_int,
        values.minute_int,
      )
    end

    def add_error(error)
      @errors << error
    end
  end
end
