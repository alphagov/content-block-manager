class DetailsValidator < ActiveModel::Validator
  module CustomValidators
    def format_date_minimum(body)
      proc do |instance, schema, _instance_location|
        return true unless instance.is_a?(String)
        return true unless schema["format"] == "date"

        min_str = schema["formatMinimum"]
        return true if min_str.nil?

        if min_str.is_a?(Hash)
          lookup = min_str["$ref"].delete_prefix("#").split("/").compact_blank
          min_str = body.dig(*lookup)
        end

        inst = Date.iso8601(instance)
        min  = Date.iso8601(min_str)

        inst >= min ? true : "formatMinimum"
      rescue Date::Error
        true # If the date is invalid, this will have been caught by the date validator, so return true
      end
    end
  end
end
