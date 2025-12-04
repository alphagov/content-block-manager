class Document::Diff::DiffBlockComponent < ViewComponent::Base
  def initialize(current_edition: ,published_edition:)
    @current_edition = current_edition
    @published_edition = published_edition
    @document = current_edition.document
  end

  private

  attr_reader :current_edition, :published_edition, :document

  def block_content
    current_content = content_tag(:div, class: "govspeak compare-editions") do
      current_edition.render
    end
    current_content

    published_content = content_tag(:div, class: "govspeak compare-editions") do
      published_edition.render
    end
    published_content

    content
    helpers.diff_html(current_content, published_content)
  end


  def data_attributes
    {
      module: "copy-embed-code",
      "embed-code-details": "default block",
      "testid": "default_block",
    }
  end
end