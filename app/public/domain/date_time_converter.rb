class DateTimeConverter
  class << self
    def from_object(date_object:, field_name:)
      DateTimeConverter.new(Time.zone.local(*(1..5).map { |index| date_object["#{field_name}(#{index}i)"].to_i }))
    end

    def from_strings(date:, time:)
      DateTimeConverter.new(Time.zone.parse("#{date} #{time}"))
    end
  end

  def initialize(date_time)
    @date_time = date_time
  end

  attr_reader :date_time

  def to_date_string
    date_time.strftime("%Y-%m-%d")
  end

  def to_time_string
    date_time.strftime("%H:%M")
  end
end
