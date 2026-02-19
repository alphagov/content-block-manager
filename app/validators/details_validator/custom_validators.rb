class DetailsValidator < ActiveModel::Validator
  module CustomValidators
    def format_date_minimum
      proc do |instance, schema, _instance_location|
        return true unless instance.is_a?(String)
        return true unless schema["format"] == "date"

        min_str = schema["formatMinimum"]
        return true if min_str.nil?

        inst = Date.iso8601(instance)
        min  = Date.iso8601(min_str)

        inst >= min ? true : "formatMinimum"
      end
    end
  end
end
