module TranslationHelper
  def humanized_label(schema_name:, relative_key:, root_object: nil)
    humanized_translation(schema_name:, relative_key:, root_object:, scope: "labels")
  end

  def humanized_title(schema_name:, relative_key:, root_object: nil)
    humanized_translation(schema_name:, relative_key:, root_object:, scope: "titles")
  end

  def translated_value(key, value)
    default_path = "edition.values.#{value}"
    translation_path = "edition.values.#{key}.#{value}"

    I18n.t(translation_path, default: [default_path.to_sym, value])
  end

  def label_for_title(block_type)
    I18n.t("activerecord.attributes.edition/document.title.#{block_type}", default: nil) || I18n.t("activerecord.attributes.edition/document.title.default")
  end

  def hint_text(schema:, subschema:, field:)
    translation_lookup = [
      schema.block_type,
      subschema&.block_type,
      field.name,
    ].compact.join(".")

    I18n.t("edition.hints.#{translation_lookup}", default: nil)
  end

private

  def humanized_translation(schema_name:, relative_key:, root_object:, scope:)
    translation_path = [
      schema_name,
      root_object,
      relative_key,
    ].compact.join(".")

    I18n.t(
      "edition.#{scope}.#{translation_path}",
      default: relative_key.humanize.gsub("-", " "),
    )
  end
end
