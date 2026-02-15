module SchemaHelpers
  MINIMAL_CONTACT_SCHEMA_BODY =
    { "type" => "object",
      "properties" =>
      { "addresses" =>
        { "type" => "object",
          "patternProperties" =>
          { ".*" =>
            { "type" => "object",
              "properties" =>
              { "state_or_county" => { "type" => "string" },
                "street_address" => { "type" => "string" },
                "title" => { "type" => "string" },
                "town_or_city" => { "type" => "string" } } } } } } }.freeze

  def stub_request_for_schema(block_type, subschemas: [], fields: nil)
    schema = double(
      id: "content_block_type",
      fields: fields || [
        build(:field, name: "foo", component_name: "string", enum_values: nil, default_value: nil, is_required?: false, data_attributes: nil),
        build(:field, name: "bar", component_name: "string", enum_values: nil, default_value: nil, is_required?: false, data_attributes: nil),
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
  config.include SchemaHelpers, type: :component
end
