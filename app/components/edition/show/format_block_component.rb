class Edition::Show::FormatBlockComponent < ViewComponent::Base
  def initialize(edition:, format:)
    @edition = edition
    @document = edition.document
    @format = format
  end

private

  attr_reader :edition, :document, :format

  def title
    format.humanize
  end

  def block_content
    content = content_tag(:div, class: "govspeak") do
      edition.render(embed_code_for_format)
    end
    content << embed_code_element

    content
  end

  def embed_code_element
    return unless edition.show_embed_codes?

    content_tag(
      :p,
      embed_code_for_format,
      class: "app-c-content-block-manager-format-block__embed_code",
    )
  end

  def embed_code_for_format
    @embed_code_for_format ||= document.embed_code_for_format(format)
  end

  def data_attributes
    return { "testid": "format_block" } unless edition.show_embed_codes?

    {
      module: "copy-embed-code",
      "embed-code": embed_code_for_format,
      "embed-code-details": "format block",
      "testid": "format_block",
    }
  end
end
