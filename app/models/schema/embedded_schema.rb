class Schema
  class EmbeddedSchema < Schema
    attr_reader :parent_schema

    def initialize(id, body, parent_schema, config = nil)
      @parent_schema = parent_schema
      @config = config
      body = body["patternProperties"].present? ? body["patternProperties"].values.first : body
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

    def permitted_params
      fields.map do |field|
        if field.format == "array"
          { field.name => [*field.array_items["properties"]&.keys, "_destroy"] || [] }
        elsif field.nested_fields.present?
          { field.name => field.nested_fields.map(&:name) }
        else
          field.name
        end
      end
    end

  private

    def field_names
      sort_fields @body["properties"].keys
    end
  end
end
