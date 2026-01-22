class PreviewContent < Data.define(:title, :html, :instances_count)
  class << self
    def for_content_id(content_id:, edition:, base_path: nil, locale: "en")
      content_item = Public::Services.publishing_api.get_content(content_id, { locale: }).parsed_content
      metadata = Public::Services.publishing_api.get_host_content_item_for_content_id(
        edition.document.content_id,
        content_id,
        { locale: },
      ).parsed_content
      html = GeneratePreviewHtml.new(
        content_id:,
        edition:,
        base_path: base_path || content_item["base_path"],
        locale:,
      ).call

      PreviewContent.new(
        title: content_item["title"],
        html:,
        instances_count: metadata["instances"],
      )
    end
  end
end
