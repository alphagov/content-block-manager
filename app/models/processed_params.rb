class ProcessedParams
  def initialize(params, schema)
    @params = params
    @schema = schema
  end

  def result
    process_fields!
    params
  end

private

  attr_reader :schema, :params

  def process_fields!
    schema.fields.each do |field|
      update_conditional_object(field) if conditional_object_field?(field)
    end
  end

  def conditional_object_field?(field)
    field.format == "object" && field.show_field
  end

  def update_conditional_object(field)
    block_type = field.schema.block_type

    details_collection = params[block_type]
    return unless details_collection

    object_data = details_collection[field.name]
    return unless object_data

    toggle_field_name = field.show_field.name

    is_visible = cast_to_boolean(object_data[toggle_field_name])
    object_data[toggle_field_name] = is_visible

    unless is_visible
      details_collection[field.name] = {}
    end
  end

  def cast_to_boolean(value)
    ActiveRecord::Type::Boolean.new.cast(value) || false
  end
end
