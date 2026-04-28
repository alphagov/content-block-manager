class Schema::Field
  module Configuration
    extend ActiveSupport::Concern

    HIDDEN_FIELD_PROPERTY_KEY = "x-hidden-field".freeze
    GOVSPEAK_ENABLED_PROPERTY_KEY = "x-govspeak-enabled".freeze
    CHARACTER_LIMIT_PROPERTY_KEY = "x-character-limit".freeze
    SHOW_FIELD_NAME_PROPERTY_KEY = "x-show-field-name".freeze
    COMPONENT_NAME_PROPERTY_KEY = "x-component-name".freeze
    FIELD_ORDERING_RULE_PROPERTY_KEY = "x-field-order".freeze

    def hidden?
      @hidden ||= properties[HIDDEN_FIELD_PROPERTY_KEY] == true
    end

    def govspeak_enabled?
      @govspeak_enabled ||= properties[GOVSPEAK_ENABLED_PROPERTY_KEY] == true
    end

    def character_limit
      @character_limit ||= properties[CHARACTER_LIMIT_PROPERTY_KEY]
    end

    def show_field
      @show_field ||= properties[SHOW_FIELD_NAME_PROPERTY_KEY] ? nested_field(properties[SHOW_FIELD_NAME_PROPERTY_KEY]) : nil
    end

    def component_name
      if custom_component
        custom_component
      elsif enum_values
        "enum"
      else
        type
      end
    end

    def field_ordering_rule
      @field_ordering_rule ||= properties.dig("items", FIELD_ORDERING_RULE_PROPERTY_KEY) || []
    end

  private

    def custom_component
      @custom_component ||= properties[COMPONENT_NAME_PROPERTY_KEY]
    end
  end
end
