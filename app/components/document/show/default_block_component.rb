class Document::Show::DefaultBlockComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

private

  attr_reader :document

  def edition
    @edition = document.most_recent_edition
  end

  def block_content
    content = content_tag(:div, class: "govspeak") do
      edition.render(embed_code)
    end
    content << embed_code_element

    content
  end

  def embed_code_element
    content_tag(:p, embed_code, class: "app-c-content-block-manager-default-block__embed_code")
  end

  def embed_code
    @embed_code ||= document.embed_code
  end

  def data_attributes
    {
      module: "copy-embed-code",
      "embed-code": embed_code,
      "embed-code-details": "default block",
      "testid": "default_block",
    }
  end
end
