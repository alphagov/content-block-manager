class Document::DocumentFilter
  FILTER_ERROR = Data.define(:attribute, :full_message)
  DEFAULT_PAGE_SIZE = 10

  def initialize(filters = {})
    @filters = filters
  end

  def paginated_documents
    unpaginated_documents.page(page).per(DEFAULT_PAGE_SIZE)
  end

  def errors
    @errors ||= begin
      @errors = []
      from = validate_date(:last_updated_from)
      to = validate_date(:last_updated_to)

      if @errors.empty? && to.present? && from.present? && from.after?(to)
        @errors << FILTER_ERROR.new(attribute: "last_updated_from", full_message: I18n.t("document.index.errors.date.range.invalid"))
      end

      @errors
    end
  end

  def valid?
    errors.empty?
  end

private

  def validate_date(key)
    return unless is_date_present?(key)

    date = date_from_filters(key)
    Time.zone.local(date[:year], date[:month], date[:day])
  rescue ArgumentError, TypeError, NoMethodError, RangeError
    @errors << FILTER_ERROR.new(attribute: key.to_s, full_message: I18n.t("document.index.errors.date.invalid", attribute: key.to_s.humanize))
    nil
  end

  def page
    @filters[:page].presence || 1
  end

  def is_date_present?(date_key)
    @filters[date_key].present? && @filters[date_key].any? { |_, value| value.present? }
  end

  def date_from_filters(date_key)
    filter = @filters[date_key]
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
    documents = Document
    documents = documents.where(block_type: Schema.valid_schemas)
    documents = documents.where(testing_artefact: false) unless Current.user&.is_e2e_user?
    documents = documents.live
    documents = documents.joins(:latest_published_edition)
    documents = documents.where(id: ids_with_keyword(keyword)) if keyword.present?
    documents = documents.where(block_type: @filters[:block_type]) if @filters[:block_type].present?
    documents = documents.with_lead_organisation(@filters[:lead_organisation]) if @filters[:lead_organisation].present?
    documents = documents.last_updated_after(from_date) if valid? && from_date
    documents = documents.last_updated_before(to_date) if valid? && to_date
    documents.order("editions.updated_at DESC")
  end

  def ids_with_keyword(filter)
    Document.with_keyword(filter).pluck(:id)
  end

  def keyword
    @keyword ||= if @filters[:keyword] && embed_code_from_keyword.present?
                   "{{embed:#{embed_code_from_keyword.document_type}:#{embed_code_from_keyword.identifier}}}"
                 else
                   @filters[:keyword]
                 end
  end

  def embed_code_from_keyword
    @embed_code_from_keyword ||= begin
      ContentBlockTools::ContentBlockReference.from_string(@filters[:keyword])
    rescue ContentBlockTools::InvalidEmbedCodeError
      nil
    end
  end
end
