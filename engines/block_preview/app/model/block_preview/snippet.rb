class BlockPreview::Snippet
  class << self
    def from_html(html)
      doc = Nokogiri::HTML(html)
      shown_element_paths = []

      doc.css(".content-block").map { |block|
        snippet = new(doc, block)
        next if shown_element_paths.include?(snippet.context_parent.path)

        preview_elements = snippet.context_elements.drop_while do |element|
          shown_element_paths.include?(element.path)
        end

        next if preview_elements.empty?

        shown_element_paths.concat(preview_elements.map(&:path))

        new(doc, block, preview_elements:)
      }.compact
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

    # If there is no previous element (for example, if the parent is contained within
    # a div), we keep trying until the parent element has a previous element
    parent = parent.parent while parent.previous_element.nil?

    parent
  end
end
