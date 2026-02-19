class Schema
  class Field
    attr_reader :name, :schema

    HIDDEN_FIELD_PROPERTY_KEY = "hidden_field".freeze
    GOVSPEAK_ENABLED_PROPERTY_KEY = "govspeak_enabled".freeze

    include Schema::Field::Translations

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

    def component_class
      class_name = "Edition::Details::Fields::#{component_name.camelize}Component"
      class_name.constantize
    rescue NameError
      raise("Component #{class_name} not found")
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

    def show_field
      @show_field ||= config["show_field_name"] ? nested_field(config["show_field_name"]) : nil
    end

    def nested_fields
      if format == "object"
        embedded_schema = Schema::EmbeddedSchema.new(name, properties, schema, config_for_embedded_schema)
        embedded_schema.fields
      elsif format == "array" && properties["items"]["type"] == "object"
        embedded_schema = Schema::EmbeddedSchema.new(name, properties["items"], schema, config, is_array: true)
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

    def name_attribute(index = nil)
      output = "edition[details]"
      parent_schemas.each { |parent_schema| output += parent_schema.html_name_part(index) }
      output + name_attribute_part(index)
    end

    def name_attribute_part(index = nil)
      name_part = "[#{name}]"
      name_part += "[#{index}]" if format == "array"
      name_part
    end

    def id_attribute(indexes = [])
      output = "edition_details"
      parent_schemas.each do |parent_schema|
        index = parent_schema.is_array? ? indexes.shift : nil
        output += parent_schema.html_id_part(index)
      end
      output + id_attribute_part(indexes.shift)
    end

    def id_attribute_part(index = nil)
      id_part = "_#{name}"
      id_part += "_#{index}" if format == "array" && index.present?
      id_part
    end

    def error_key(indexes = [])
      id_attribute(indexes).delete_prefix("edition_")
    end

    def value_lookup_path(index = nil)
      path = []
      parent_schemas.each { |parent_schema| path << parent_schema.value_lookup_parts(index) }
      path << name
      path << index if format == "array"
      path.flatten
    end

    def permitted_params
      if format == "array" && nested_fields.present?
        { name => [*nested_fields.map(&:permitted_params), "_destroy"] || [] }
      elsif format == "array"
        { name => [*array_items["properties"]&.keys, "_destroy"] || [] }
      elsif format == "object" && properties["subtype"] == "date_range" && properties["required"]
        { name => properties["required"].flat_map { |required_field| (1..5).map { |i| "#{required_field}(#{i}i)" } } }
      elsif nested_fields.present?
        { name => nested_fields.map(&:permitted_params) }
      else
        name
      end
    end

  private

    def config_for_embedded_schema
      return schema.config.dig("subschemas", name) if schema.config["subschemas"]

      config
    end

    def custom_component
      @custom_component ||= config["component"]
    end

    def properties
      @properties ||= schema.body.dig("properties", name) || {}
    end

    def field_ordering_rule
      @field_ordering_rule ||= config["field_order"] || []
    end

    def root_schema
      @root_schema ||= parent_schemas.any? ? parent_schemas[0].parent_schema : schema
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
