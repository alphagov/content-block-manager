module HasSubschema
  extend ActiveSupport::Concern

  def get_schema_and_subschema(block_type, object_type)
    schema = get_schema(block_type)
    subschema = get_subschema(schema, object_type)

    [schema, subschema]
  end

  def get_schema(block_type)
    Schema.find_by_block_type(block_type)
  end

  def get_subschema(schema, object_type)
    schema.subschema(object_type) or raise(ActionController::RoutingError, "Subschema for #{object_type} not found")
  end

  def object_params(subschema)
    processed_params(subschema).require("edition").permit(
      details: {
        subschema.block_type.to_s => subschema.permitted_params,
      },
    )
  end

  def processed_params(subschema)
    params["edition"]["details"] = ProcessedParams.new(
      params["edition"]["details"],
      subschema,
    ).result
    params
  end

  def validate_and_convert_object(object_params)
    validator_class = validator_for_subschema
    return object_params unless validator_class

    validator_class.new(@edition, object_params).validate_and_convert
  end

  def validator_for_subschema
    "#{@subschema.block_type.camelize}Validator".safe_constantize
  end
end
