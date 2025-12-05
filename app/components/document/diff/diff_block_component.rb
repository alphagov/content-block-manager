class Document::Diff::DiffBlockComponent < ViewComponent::Base
  def initialize(current_edition: ,published_edition:)
    @current_edition = current_edition
    @published_edition = published_edition
    @document = current_edition.document
  end

  private

  attr_reader :current_edition, :published_edition, :document

  def block_content
    current_content = content_tag(:div, class: "govspeak") do
      current_edition.render.html_safe
    end

    published_content = content_tag(:div, class: "govspeak") do
      published_edition.render.html_safe
    end

    CGI.unescapeHTML(helpers.diff_html(current_content.html_safe, published_content.html_safe).html_safe)
  end
end

