class Schema::Field
  module Translations
    extend ActiveSupport::Concern
    included do
      def label
        I18n.t(translation_lookup_path("labels"), default: default_translation_value)
      end

      def title
        I18n.t(translation_lookup_path("titles"), default: default_translation_value)
      end

      def hint
        I18n.t(translation_lookup_path("hints"), default: nil)
      end

      def error_message(error_type, **args)
        path = [
          "activerecord.errors.models",
          translation_lookup_path("attributes"),
          error_type,
        ].join(".")
        default = I18n.t("activerecord.errors.models.edition.#{error_type}", attribute: label, **args)
        I18n.t(path, default:, **args)
      end

    private

      def default_translation_value
        name.humanize.gsub("-", " ")
      end

      def translation_lookup_path(type)
        [
          "edition",
          type,
          root_schema.block_type,
          *parent_schemas.map(&:id),
          name,
        ].join(".")
      end
    end
  end
end
