class HtmlDiffer
  def initialize(before_html, after_html)
    @before = Nokogiri::HTML.fragment(before_html)
    @after = Nokogiri::HTML.fragment(after_html)
  end

  def generate_diff
    result = @after.dup

    before_texts = collect_text_nodes(@before)
    after_texts = collect_text_nodes(result)

    after_texts.each_with_index do |after_node, index|
      before_node = before_texts[index]

      next unless before_node
      next if before_node.content.strip == after_node.content.strip

      replace_with_diff(after_node, before_node.content, after_node.content)
    end

    result.to_html
  end

private

  def collect_text_nodes(doc)
    nodes = []
    doc.traverse do |node|
      nodes << node if node.text? && !node.content.strip.empty?
    end
    nodes
  end

  def replace_with_diff(node, old_content, new_content)
    diff = Diffy::Diff.new(old_content, new_content, context: 0)
    node.replace(diff.to_s(:html))
  end
end
