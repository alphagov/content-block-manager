class BlockPreview::DynamicPreviewHeader < ViewComponent::Base
  def initialize(block:, title:)
    @block = block
    @title = title
  end

  def options
    published = { text: render_title(published_edition),
                  value: "published",
                  selected: params[:block] != "draft" }

    return [published] if most_recent_edition.id == published_edition.id

    draft = { text: render_title(most_recent_edition),
              value: "draft",
              selected: params[:block] == "draft" }

    [draft, published]
  end

private

  def most_recent_edition
    @block.document.most_recent_edition
  end

  def published_edition
    @block.document.latest_published_edition
  end

  def render_title(edition)
    "#{edition.state.humanize} - #{@edition.title}"
  end
end
