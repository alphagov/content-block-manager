class Schema
  class EmbeddedSchema < Schema
    attr_reader :parent_schema

    def initialize(id, body, parent_schema, config = nil, is_array: false)
      @parent_schema = parent_schema
      @config = config
      @is_array = is_array
      @pattern_properties_present = body["patternProperties"].present?
      body = @pattern_properties_present ? body["patternProperties"].values.first : body
      super(id, body)
    end

    def block_type
      @id
    end

    def embeddable_as_block?
      @embeddable_as_block ||= config["embeddable_as_block"].present?
    end

    def config
      @config ||= self.class.schema_settings.dig("schemas", parent_schema.id, "subschemas", @id) || {}
    end

    def group
      @group ||= config["group"]
    end

    def group_order
      @group_order ||= config["group_order"]&.to_i || Float::INFINITY
    end

    def relationship_type
      ActiveSupport::StringInquirer.new(@pattern_properties_present ? "one_to_many" : "one_to_one")
    end

  private

    def field_names
      sort_fields @body["properties"].keys
    end
  end
end
