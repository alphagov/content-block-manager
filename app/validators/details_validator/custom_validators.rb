class DetailsValidator < ActiveModel::Validator
  module CustomValidators
    def format_date_minimum(body)
      proc do |instance, schema, _instance_location|
        next true unless instance.is_a?(String)

        format = schema["format"]
        min_str = schema["formatMinimum"]
        next true if min_str.nil?

        unless format == "date-time"
          raise ArgumentError, "formatMinimum is only supported for date-time fields, got format: #{format.inspect}"
        end

        if min_str.is_a?(Hash)
          lookup = min_str["$ref"].delete_prefix("#").split("/").compact_blank
          min_str = body.dig(*lookup)
        end

        inst = Time.iso8601(instance)
        min  = Time.iso8601(min_str)
        inst > min ? true : "formatMinimum"
      rescue ArgumentError => e
        raise e if e.message.include?("formatMinimum is only supported")

        true # If the datetime is invalid, this will have been caught by another validator
      end
    end
  end
end
