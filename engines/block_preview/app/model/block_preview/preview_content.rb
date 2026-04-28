module BlockPreview
  class PreviewContent
    VALID_STATES = %w[published draft].freeze

    attr_reader :state, :content_id, :block, :base_path, :locale

    def initialize(content_id:, block:, base_path: nil, locale: "en", state: "published")
      @content_id = content_id
      @block = block
      @base_path = base_path
      @locale = locale
      @state = validated_state(state)
    end

    def title
      @title ||= content_item["title"]
    end

    def html
      @html ||= BlockPreview::PreviewHtml.new(
        content_id:,
        block:,
        base_path: base_path || content_item["base_path"],
        locale:,
        state:,
        auth_bypass_id: content_item["auth_bypass_ids"]&.first,
      ).to_s
    end

    def instances_count
      metadata["instances"]
    end

  private

    def validated_state(state)
      return state if VALID_STATES.include?(state)

      raise ArgumentError, "state must be one of: #{VALID_STATES.join(', ')}"
    end

    def content_item
      @content_item ||= Public::Services.publishing_api.get_content(content_id, { locale:, content_store: }).parsed_content
    end

    def metadata
      @metadata ||= Public::Services.publishing_api.get_host_content_item_for_content_id(
        block.content_id,
        content_id,
        { locale:, state: },
      ).parsed_content
    end

    def content_store
      state == "draft" ? "draft" : "live"
    end
  end
end
