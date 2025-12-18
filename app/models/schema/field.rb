class Schema
  class Field
    attr_reader :name, :schema

    HIDDEN_FIELD_PROPERTY_KEY = "hidden_field".freeze
    GOVSPEAK_ENABLED_PROPERTY_KEY = "govspeak_enabled".freeze

    def initialize(name, schema)
      @name = name
      @schema = schema
    end

    def to_s
      name
    end

    def component_name
      if custom_component
        custom_component
      elsif enum_values
        "enum"
      else
        format
      end
    end

    def config
      @config ||= schema.config.dig("fields", name) || {}
    end

    def format
      @format ||= properties["type"]
    end

    def enum_values
      @enum_values ||= properties["enum"]
    end

    def default_value
      @default_value ||= properties["default"]
    end

    def nested_fields
      if format == "object"
        embedded_schema = Schema::EmbeddedSchema.new(name, properties, schema, config)
        embedded_schema.fields
      elsif format == "array" && properties["items"]["type"] == "object"
        embedded_schema = Schema::EmbeddedSchema.new(name, properties["items"], schema, config)
        embedded_schema.fields
      end
    end

    def nested_field(name)
      raise(ArgumentError, "Provide the name of a nested field") if name.blank?

      nested_fields.find { |field| field.name == name }
    end

    def array_items
      properties.fetch("items", nil)&.tap do |array_items|
        if array_items["type"] == "object"
          array_items["properties"] = array_items["properties"].sort_by { |k, _v|
            field_ordering_rule.find_index(k) || Float::INFINITY
          }.to_h
        end
      end
    end

    def is_required?
      schema.required_fields.include?(name)
    end

    def data_attributes
      @data_attributes ||= config["data_attributes"] || {}
    end

    def hidden?
      @hidden ||= config[HIDDEN_FIELD_PROPERTY_KEY] == true
    end

    def govspeak_enabled?
      @govspeak_enabled ||= config[GOVSPEAK_ENABLED_PROPERTY_KEY] == true
    end

    def name_attribute
      output = "edition[details]"
      parent_schemas.each { |parent_schema| output += "[#{parent_schema.block_type}]" }
      output + "[#{name}]"
    end

    def id_attribute
      output = "edition_details"
      parent_schemas.each { |parent_schema| output += "_#{parent_schema.block_type}" }
      output + "_#{name}"
    end

    def error_key
      id_attribute.delete_prefix("edition_")
    end

  private

    def custom_component
      @custom_component ||= config["component"]
    end

    def properties
      @properties ||= schema.body.dig("properties", name) || {}
    end

    def field_ordering_rule
      @field_ordering_rule ||= config["field_order"] || []
    end

    def parent_schemas
      @parent_schemas ||= [].tap { |parents|
        current = schema

        while current.respond_to?(:parent_schema)
          parents << current
          current = current.parent_schema
        end
      }.reverse
    end
  end
end
