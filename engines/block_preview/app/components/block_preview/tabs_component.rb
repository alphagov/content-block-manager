class BlockPreview::TabsComponent < ViewComponent::Base
  include BlockPreview::Engine.routes.url_helpers

  def initialize(snippet_count:, current_tab:, block:, preview_content:)
    @snippet_count = snippet_count
    @current_tab = current_tab
    @block = block
    @preview_content = preview_content
  end

private

  attr_reader :snippet_count, :current_tab, :block, :preview_content

  def url_for_tab(tab)
    host_content_preview_path(
      edition_id: block.id,
      host_content_id: preview_content.content_id,
      locale: preview_content.locale,
      state: preview_content.state,
      tab:,
    )
  end
end
