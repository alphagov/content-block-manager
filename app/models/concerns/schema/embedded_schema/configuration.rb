class Schema::EmbeddedSchema
  module Configuration
    extend ActiveSupport::Concern

    EMBEDDABLE_AS_BLOCK_PROPERTY_KEY = "x-embeddable-as-block".freeze
    GROUP_PROPERTY_KEY = "x-group".freeze
    GROUP_ORDER_PROPERTY_KEY = "x-group-order".freeze

    def embeddable_as_block?
      @embeddable_as_block ||= @body[EMBEDDABLE_AS_BLOCK_PROPERTY_KEY].present?
    end

    def group
      @group ||= @body[GROUP_PROPERTY_KEY]
    end

    def group_order
      @group_order ||= @body[GROUP_ORDER_PROPERTY_KEY]&.to_i || Float::INFINITY
    end
  end
end
