module V2
  class Document
    class DocumentFilter
      class InvalidFiltersError < StandardError
        attr_reader :errors

        def initialize(errors)
          @errors = errors
          super
        end
      end

      FILTER_ERROR = Data.define(:attribute, :full_message)
      DEFAULT_PAGE_SIZE = 10

      attr_reader :filters

      def initialize(filters = {})
        @filters = filters
      end

      def call
        validate_filters
        unpaginated_documents.page(page).per(DEFAULT_PAGE_SIZE)
      end

    private

      def validate_format_of_organisation_uuid
        return if organisation_not_supplied?
        return if organisation_format_valid?

        @errors << FILTER_ERROR.new(attribute: "lead_organisation", full_message: I18n.t("document.index.errors.lead_organisation.invalid"))
      end

      def validate_filters
        @errors = []
        from = validate_date(:last_updated_from)
        to = validate_date(:last_updated_to)
        validate_format_of_organisation_uuid

        if @errors.empty? && start_date_is_later_than_end_date(from, to)
          @errors << FILTER_ERROR.new(attribute: "last_updated_from_3i", full_message: I18n.t("document.index.errors.date.range.invalid"))
        end

        raise InvalidFiltersError, @errors if @errors.any?
      end

      def validate_date(key)
        return unless is_date_present?(key)

        date = date_from_filters(key)
        Time.zone.local(date[:year], date[:month], date[:day])
      rescue ArgumentError, TypeError, NoMethodError, RangeError
        @errors << FILTER_ERROR.new(attribute: "#{key}_3i", full_message: I18n.t("document.index.errors.date.invalid", attribute: key.to_s.humanize))
        nil
      end

      def page
        filters[:page].presence || 1
      end

      def is_date_present?(date_key)
        filters[date_key].present? && filters[date_key].any? { |_, value| value.present? }
      end

      def date_from_filters(date_key)
        filter = filters[date_key]
        year = filter["1i"].to_i
        month = filter["2i"].to_i
        day = filter["3i"].to_i
        { year:, month:, day: }
      end

      def from_date
        @from_date ||= if is_date_present?(:last_updated_from)
                         date = date_from_filters(:last_updated_from)
                         Time.zone.local(date[:year], date[:month], date[:day])
                       end
      end

      def to_date
        @to_date ||= if is_date_present?(:last_updated_to)
                       date = date_from_filters(:last_updated_to)
                       Time.zone.local(date[:year], date[:month], date[:day]).end_of_day
                     end
      end

      def unpaginated_documents
        documents = V2::Document.all
        documents = documents.where(id: ids_with_keyword(keyword)) if keyword.present?

        documents
            .where_block_type(filters[:block_type])
            .where_lead_organisation(filters[:lead_organisation])
            .where_last_updated_after(from_date)
            .where_last_updated_before(to_date)
            .by_most_recently_created_edition
      end

      def ids_with_keyword(filter)
        V2::Document.where_keyword(filter).pluck(:id)
      end

      def keyword
        @keyword ||= if filters[:keyword].present? && embed_code_from_keyword.present?
                       "{{embed:#{embed_code_from_keyword.document_type}:#{embed_code_from_keyword.identifier}}}"
                     else
                       filters[:keyword]
                     end
      end

      def embed_code_from_keyword
        @embed_code_from_keyword ||= begin
          ContentBlockTools::ContentBlockReference.from_string(filters[:keyword])
        rescue ContentBlockTools::InvalidEmbedCodeError
          nil
        end
      end

      def organisation_not_supplied?
        filters[:lead_organisation].blank? ||
          filters[:lead_organisation].empty?
      end

      def organisation_format_valid?
        Patterns::UUID.match?(filters[:lead_organisation])
      end

      def start_date_is_later_than_end_date(from_date, to_date)
        from_date.present? && to_date.present? && from_date.after?(to_date)
      end
    end
  end
end
