class DateTimeConverter
  class << self
    def from_object(date_object:, field_name:)
      DateTimeConverter.new(Time.zone.local(*(1..5).map { |index| date_object["#{field_name}(#{index}i)"].to_i }))
    end
  end

  def initialize(date_time)
    @date_time = date_time
  end

  attr_reader :date_time

end
