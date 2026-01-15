def required_fields(subschema, object_name)
  subschema.field(object_name.pluralize).nested_fields.select(&:is_required?).map(&:name)
end
