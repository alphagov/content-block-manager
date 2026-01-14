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
      next unless collection[field.name]

      if conditional_object_field?(field)
        collection[field.name] = update_conditional_object(field, collection[field.name])
      elsif field.nested_fields && field.format == "object"
        collection[field.name] = processed_fields(field.nested_fields, collection[field.name])
      elsif field.nested_fields && field.format == "array"
        collection[field.name] = collection[field.name].map { |item| processed_fields(field.nested_fields, item) }
      end
    end
    collection
  end

  def conditional_object_field?(field)
    field.format == "object" && field.show_field
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
end
