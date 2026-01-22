module BlockPreview
  class PreviewContent
    def initialize(content_id:, block:, base_path: nil, locale: "en")
      @content_id = content_id
      @block = block
      @base_path = base_path
      @locale = locale
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
      ).to_s
    end

    def instances_count
      metadata["instances"]
    end

  private

    attr_reader :content_id, :block, :base_path, :locale

    def content_item
      @content_item ||= Public::Services.publishing_api.get_content(content_id, { locale: }).parsed_content
    end

    def metadata
      @metadata ||= Public::Services.publishing_api.get_host_content_item_for_content_id(
        block.content_id,
        content_id,
        { locale: },
      ).parsed_content
    end
  end
end
