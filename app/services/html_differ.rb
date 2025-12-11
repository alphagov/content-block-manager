require "diff/lcs"

class HtmlDiffer
  def initialize(before_html, after_html)
    @before = Nokogiri::HTML.fragment(before_html)
    @after = Nokogiri::HTML.fragment(after_html)
  end

  def to_html
    compare_blocks.map do |diff|
      case diff[:status]
      when :unchanged
        diff[:a].to_html
      when :changed
        %Q{
        <div class="diff">
           <del>#{char_diff_html(diff[:a].to_html, diff[:b].to_html).first}</del>
        </div>
        <div class="diff">
            <ins>#{char_diff_html(diff[:a].to_html, diff[:b].to_html).last}</ins>
        </div>
        }
      when :deleted
        %Q{
        <div class="diff">
          <del>#{diff[:a].to_html}</del>
        </div>
        }
      when :added
        %Q{
        <div class="diff">
          <ins>#{diff[:b].to_html}</ins>
        </div>
        }
      end
    end.join("\n")
  end

  private

  def compare_blocks
    before_nodes = @before.children.to_a
    after_nodes = @after.children.to_a

    max = [before_nodes.length, after_nodes.length].max

    max.times.map do |i|
      a = before_nodes[i]
      b = after_nodes[i]

      if a && b
        if a.to_html.strip == b.to_html.strip
          {status: :unchanged, a: a, b: b}
        else
          {status: :changed, a: a, b: b}
        end
      elsif a
        {status: :deleted, a: a, b: nil}
      elsif b
        {status: :deleted, a: nil, b: b}
      end
    end
  end

  def char_diff_html(old_html, new_html)
    old_text = strip_tags(old_html)
    new_text = strip_tags(new_html)

    old_set = old_text.chars
    new_set = new_text.chars

    diff = Diff::LCS.sdiff(old_set, new_set)

    old_out = ""
    new_out = ""

    diff.each do |change|
      case change.action
      when "="
        old_out << change.old_element
        new_out << change.new_element
      when "!"
        old_out << "<strong>#{change.old_element}</strong>"
        new_out << "<strong>#{change.new_element}</strong>"
      when "-"
        old_out << "<strong>#{change.old_element}</strong>"
      when "+"
        new_out << "<strong>#{change.new_element}</strong>"
      end
    end

    [wrap_text_with_tags(old_html, old_out), wrap_text_with_tags(new_html, new_out)]
  end

  def strip_tags(html)
    Nokogiri::HTML.fragment(html).text
  end

  def wrap_text_with_tags(original_html, new_text)
    frag = Nokogiri::HTML.fragment(original_html)
    new_frag = Nokogiri::HTML.fragment(new_text)

    frag.children.remove
    new_frag.children.each do |child|
      frag.add_child(child)
    end

    frag.to_html
  end
end