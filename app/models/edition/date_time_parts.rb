class Edition
  class DateTimeParts
    def initialize(edition:, params:, block_type:, field_name:, date_field:, time_field:)
      @edition = edition
      @params = params
      @block_type = block_type
      @field_name = field_name
      @date_field = date_field
      @time_field = time_field
    end

    def year
      part_for(param_key: "#{date_field.name}(1i)", parsed_time_part: :year)
    end

    def month
      part_for(param_key: "#{date_field.name}(2i)", parsed_time_part: :month)
    end

    def day
      part_for(param_key: "#{date_field.name}(3i)", parsed_time_part: :day)
    end

    def hour
      part_for(param_key: "#{time_field.name}(4i)", parsed_time_part: :hour)
    end

    def min
      part_for(param_key: "#{time_field.name}(5i)", parsed_time_part: :min)
    end

    def parsed_time
      @parsed_time ||= parse_time_from_details
    end

  private

    attr_reader :edition, :params, :block_type, :field_name, :date_field, :time_field

    def part_for(param_key:, parsed_time_part:)
      value = param_value(param_key)
      return value unless value.nil?

      parsed_time&.public_send(parsed_time_part)
    end

    def param_value(key)
      params.dig(:edition, :details, block_type, field_name, key)
    end

    def parse_time_from_details
      date = edition.details.dig(block_type, field_name, date_field.name) || ""
      time = edition.details.dig(block_type, field_name, time_field.name) || ""
      Time.zone.iso8601("#{date}T#{time}")
    rescue ArgumentError
      nil
    end
  end
end
