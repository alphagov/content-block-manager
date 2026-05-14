class Schema
  module Configuration
    extend ActiveSupport::Concern

    FORMATS_PROPERTY_KEY = "x-formats".freeze
    BLOCK_DISPLAY_FIELDS_PROPERTY_KEY = "x-block-display-fields".freeze
    EMBEDDABLE_AS_BLOCK_PROPERTY_KEY = "x-embeddable-as-block".freeze
    FIELD_ORDER_PROPERTY_KEY = "x-field-order".freeze

    def formats
      @body[FORMATS_PROPERTY_KEY] || []
    end

    def block_display_fields
      @body[BLOCK_DISPLAY_FIELDS_PROPERTY_KEY] || []
    end

    def embeddable_as_block?
      @body[EMBEDDABLE_AS_BLOCK_PROPERTY_KEY].present?
    end

    def field_order
      @field_order ||= @body[FIELD_ORDER_PROPERTY_KEY]
    end
  end
end
