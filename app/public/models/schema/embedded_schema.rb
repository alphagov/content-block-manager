class Schema
  class EmbeddedSchema < Schema
    attr_reader :parent_schema

    include Schema::EmbeddedSchema::Configuration

    def initialize(id, body, parent_schema, is_array: false)
      @parent_schema = parent_schema
      @is_array = is_array
      @pattern_properties_present = body["patternProperties"].present?
      body = @pattern_properties_present ? body["patternProperties"].values.first : body
      super(id, body)
    end

    def block_type
      @id
    end

    def relationship_type
      ActiveSupport::StringInquirer.new(@pattern_properties_present ? "one_to_many" : "one_to_one")
    end

    def datetime_fields
      fields.select(&:datetime_format?)
    end

  private

    def field_names
      sort_fields @body["properties"].keys
    end
  end
end
