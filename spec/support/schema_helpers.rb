module SchemaHelpers
  def stub_request_for_schema(block_type, subschemas: [], fields: nil)
    schema = double(
      id: "content_block_type",
      fields: fields || [
        double(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, is_required?: false, data_attributes: nil),
        double(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, is_required?: false, data_attributes: nil),
      ],
      name: "schema",
      body: {
        "properties" => {
          "foo" => { "type" => "string" },
          "bar" => { "type" => "string" },
        },
      },
      block_type:,
      permitted_params: %i[foo bar],
      subschemas:,
      block_display_fields: [],
      embeddable_as_block?: false,
    )
    subschemas.each do |subschema|
      allow(schema).to receive(:subschema).with(subschema.id).and_return(subschema)
    end
    allow(Schema).to receive(:find_by_block_type).with(block_type).and_return(schema)
    schema
  end
end

RSpec.configure do |config|
  config.include SchemaHelpers, type: :request
  config.include SchemaHelpers, type: :feature
end
