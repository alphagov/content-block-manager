module TranslationHelper
  def translated_value(key, value)
    default_path = "edition.values.#{value}"
    translation_path = "edition.values.#{key}.#{value}"

    I18n.t(translation_path, default: [default_path.to_sym, value])
  end

  def label_for_title(block_type)
    I18n.t("activerecord.attributes.edition/document.title.#{block_type}", default: nil) || I18n.t("activerecord.attributes.edition/document.title.default")
  end
end
