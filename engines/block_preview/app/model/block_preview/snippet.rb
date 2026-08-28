class BlockPreview::Snippet
  class << self
    def for_content_id(content_id, state:, block:, locale:)
      diff = BlockPreview::ContentDiff.new(
        html_snippet(content_id, state, locale),
        block,
      )
      from_html(diff.to_s, block)
    end

    def from_html(html, block)
      doc = Nokogiri::HTML(html)
      shown_element_paths = []

      doc.css(%([data-content-id="#{block.content_id}"])).map { |content_block|
        snippet = new(doc, content_block)
        next if shown_element_paths.include?(snippet.context_parent.path)

        preview_elements = snippet.context_elements.drop_while do |element|
          shown_element_paths.include?(element.path)
        end

        next if preview_elements.empty?

        shown_element_paths.concat(preview_elements.map(&:path))

        new(doc, content_block, preview_elements:)
      }.compact
    end

  private

    def html_snippet(content_id, state, locale)
      publishing_api_response = Public::Services.publishing_api.get_content(content_id, locale:)
      content_store = state == "published" ? Public::Services.content_store : Public::Services.draft_content_store
      content_store_response = content_store.content_item(publishing_api_response["base_path"])
      html = if %w[guide travel_advice].include?(content_store_response["document_type"])
               content_store_response["details"]["parts"].map { |part| part["body"] }.join("\n")
             else
               content_store_response["details"]["body"]
             end

      Nokogiri::HTML.fragment(html)
    end
  end

  def initialize(doc, block, preview_elements: nil)
    @doc = doc
    @block = block
    @preview_elements = preview_elements
  end

  def to_html
    context_elements.map(&:to_s).join("\n")
  end

  def context_parent_html
    context_parent.to_s
  end

  def context_parent
    get_parent
  end

  def context_elements
    @preview_elements || default_preview_elements
  end

private

  attr_reader :doc, :block

  def default_preview_elements
    parent = context_parent

    [
      parent.previous_element&.previous_element,
      parent.previous_element,
      parent,
      parent.next_element,
      parent.next_element&.next_element,
    ].compact
  end

  def get_parent
    parent = block.parent
    list_item_ancestor = block.ancestors("li").first
    table_cell_ancestor = block.ancestors("td").first

    # If the block is within a list item or a table, we want to ensure
    # the containing list/table is preserved, so we can show the surrounding
    # HTML
    if list_item_ancestor
      parent = list_item_ancestor.ancestors("ul, ol").first || list_item_ancestor
    elsif table_cell_ancestor
      parent = table_cell_ancestor.ancestors("table").first || table_cell_ancestor
    end

    # If there is no previous element, walk up the tree until we find one.
    # Stop before leaving element nodes to avoid calling `parent` on a document.
    while parent.previous_element.nil?
      break unless parent.respond_to?(:parent) && parent.parent&.element?

      parent = parent.parent
    end

    parent
  end
end
