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
