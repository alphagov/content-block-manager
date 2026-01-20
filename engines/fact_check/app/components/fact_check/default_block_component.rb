class FactCheck::DefaultBlockComponent < ViewComponent::Base
  def initialize(block:)
    @block = block
  end

private

  attr_reader :block

  def calculate_diff
    Nokodiff.diff(block.published_block.render, block.render)
  end

  def block_content
    content_tag(:div, class: "govspeak compare-editions") do
      calculate_diff
    end
  end
end
