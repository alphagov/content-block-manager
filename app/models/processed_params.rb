class ProcessedParams
  def initialize(params, schema)
    @params = params
    @schema = schema
  end

  def result
    block_type = schema.block_type
    params[block_type] = processed_fields(schema.fields, params[block_type])
    params
  end

private

  attr_reader :schema, :params

  def processed_fields(fields, collection)
    fields.each do |field|
      collection[field.name] = process_time_field(field, collection) if field.format.time?
      collection[field.name] = process_date_field(field, collection) if field.format.date?

      next unless collection[field.name]

      if conditional_object_field?(field)
        collection[field.name] = update_conditional_object(field, collection[field.name])
      elsif field.nested_fields && field.type.object?
        collection[field.name] = processed_fields(field.nested_fields, collection[field.name])
      elsif field.nested_fields && field.type.array?
        collection[field.name] = collection[field.name].map { |item| processed_fields(field.nested_fields, item) }
      end
    end
    collection
  end

  def process_date_field(field, collection)
    year = get_and_remove_date_time_part_from_collection(field, "year", collection)
    month = get_and_remove_date_time_part_from_collection(field, "month", collection).rjust(2, "0")
    day = get_and_remove_date_time_part_from_collection(field, "day", collection).rjust(2, "0")

    "#{year}-#{month}-#{day}"
  end

  def process_time_field(field, collection)
    hour = get_and_remove_date_time_part_from_collection(field, "hour", collection).rjust(2, "0")
    minute = get_and_remove_date_time_part_from_collection(field, "minute", collection).rjust(2, "0")

    "#{hour}:#{minute}"
  end

  def conditional_object_field?(field)
    field.type.object? && field.show_field
  end

  def update_conditional_object(field, collection)
    toggle_field_name = field.show_field.name

    is_visible = cast_to_boolean(collection[toggle_field_name])
    collection[toggle_field_name] = is_visible

    is_visible ? collection : {}
  end

  def cast_to_boolean(value)
    ActiveRecord::Type::Boolean.new.cast(value) || false
  end

  def get_and_remove_date_time_part_from_collection(field, part, collection)
    index = %w[year month day hour minute].index(part) + 1
    collection.delete("#{field.name}(#{index}i)") || ""
  end
end
