class Document::Show::DefaultBlockComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

private

  attr_reader :document

  def edition
    @edition = document.latest_edition
  end

  def block_content
    content_tag(:div, class: "govspeak") do
      edition.render(embed_code)
    end
  end

  def embed_code_row_value
    content_tag(:p, embed_code, class: "app-c-content-block-manager-default-block__embed_code")
  end

  def embed_code
    @embed_code ||= document.embed_code
  end

  def data_attributes
    {
      module: "copy-embed-code",
      "embed-code": embed_code,
      "link-copy-code-value": embed_code,
      controller: "link-copy",
      "link-copy-target": "code",
    }
  end
end
