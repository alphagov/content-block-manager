class BlockPreview::PreviewDetailsComponent < ViewComponent::Base
  def initialize(block:, preview_content:)
    @block = block
    @preview_content = preview_content
  end

private

  attr_reader :block, :preview_content

  def list_items
    [*details_items.compact, instances_item]
  end

  def details_items
    block.details.map do |key, value|
      next unless value.is_a?(String)

      { key: key.humanize, value: }
    end
  end

  def instances_item
    { key: "Instances", value: preview_content.instances_count }
  end
end
