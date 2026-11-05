class BlockPreview::ContentDiff
  def initialize(html, block)
    @before = html
    @block = block
  end

  delegate :to_s, to: :diff_fragment

private

  attr_reader :before, :block

  def diff_fragment
    @diff_fragment ||= begin
      fragment = Nokogiri::HTML.fragment(Nokodiff.diff(before.to_s, after.to_s))
      wrapped = Nokogiri::HTML.fragment("<div class='compare-editions'></div>")
      wrapped.at_css("div").add_child(fragment)
      wrapped.to_html
    end
  end

  def after
    @after ||= build_after_fragment
  end

  def build_after_fragment
    fragment = before.dup

    fragment.css(content_block_selector).each do |wrapper|
      wrapper.replace(block.render(wrapper["data-embed-code"]))
    end

    fragment
  end

  def content_block_selector
    %([data-content-id="#{block.content_id}"])
  end
end
