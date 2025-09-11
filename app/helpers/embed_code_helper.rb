module EmbedCodeHelper
  def copy_embed_code_data_attributes(key, document)
    {
      module: "copy-embed-code",
      "embed-code": document.embed_code_for_field(key),
    }
  end

  # This generates a row containing the embed code for the field above it -
  # it will be deleted if javascript is enabled by copy-embed-code.js.
  def embed_code_row(key, document)
    {
      key: "Embed code",
      value: document.embed_code_for_field(key),
      data: {
        "embed-code-row": "true",
      },
    }
  end
end
