module TranslationHelper
  def humanized_label(relative_key:, root_object: nil)
    translation_path = root_object ? "#{root_object}.#{relative_key}" : relative_key

    I18n.t(
      "edition.details.labels.#{translation_path}",
      default: relative_key.humanize.gsub("-", " "),
    )
  end

  def translated_value(key, value)
    default_path = "edition.details.values.#{value}"
    translation_path = "edition.details.values.#{key}.#{value}"

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
end
