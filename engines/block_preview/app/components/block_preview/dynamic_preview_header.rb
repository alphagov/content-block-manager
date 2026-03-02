class BlockPreview::DynamicPreviewHeader < ViewComponent::Base
  def initialize(block:, title:)
    @block = block
    @title = title
  end
end
