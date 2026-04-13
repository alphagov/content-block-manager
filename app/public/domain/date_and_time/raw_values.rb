module DateAndTime
  RawValues = Data.define(:year, :month, :day, :hour, :min) do
    def self.from_params(params, field_name)
      new(
        year: raw_value(params, field_name, 1),
        month: raw_value(params, field_name, 2),
        day: raw_value(params, field_name, 3),
        hour: integer_value(params, field_name, 4),
        min: integer_value(params, field_name, 5),
      )
    end

    def self.raw_value(params, field_name, index)
      value = params["#{field_name}(#{index}i)"]
      return nil if value.blank?

      value
    end

    def self.integer_value(params, field_name, index)
      value = params["#{field_name}(#{index}i)"]
      return nil if value.blank?

      value.to_i
    end
  end
end
