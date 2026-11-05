class Schema::Field
  module Translations
    extend ActiveSupport::Concern
    include ApplicationHelper

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
        # If the translated label is a hash, this means this field has nested fields, so we use the `title` as the attribute instead
        attribute = label.is_a?(String) ? label.downcase : title.downcase

        default = I18n.t(
          "activerecord.errors.models.edition.#{error_type}",
          attribute:,
          attribute_with_indefinite_article: add_indefinite_article(attribute),
          **args,
        )
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
