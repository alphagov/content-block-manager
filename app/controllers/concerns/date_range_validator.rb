class DateRangeValidator
  SUBSCHEMA_BLOCK_TYPE = "date_range".freeze

  def initialize(edition, object_params)
    @edition = edition
    @object_params = object_params
  end

  def validate_and_convert
    start_converter = validate_datetime_field("start")
    end_converter = validate_datetime_field("end")

    if start_converter.valid? && end_converter.valid?
      validate_end_after_start(start_converter, end_converter)
    end

    raise ActiveRecord::RecordInvalid, @edition if @edition.errors.any?

    converted_fields = {
      "start" => start_converter.to_iso8601,
      "end" => end_converter.to_iso8601,
    }

    strip_multiparameter_keys.merge(converted_fields)
  end

private

  def validate_datetime_field(field_name)
    converter = DateAndTime::Converter.from_params(
      params: @object_params,
      field_name: field_name,
    )

    add_datetime_errors(converter, field_name)

    converter
  end

  def add_datetime_errors(converter, field_name)
    converter.errors.each do |error|
      error_key = "details_#{SUBSCHEMA_BLOCK_TYPE}_#{field_name}"
      message = translate_datetime_error(error, field_name)
      @edition.errors.add(error_key, message)
    end
  end

  def translate_datetime_error(error, field_name)
    attribute = field_name.humanize
    case error
    when :date_blank
      I18n.t(
        "activerecord.errors.models.edition.attributes.#{field_name}.blank",
        attribute: attribute,
        default: I18n.t("activerecord.errors.models.edition.blank", attribute: attribute),
      )
    when :date_invalid
      I18n.t(
        "activerecord.errors.models.edition.attributes.#{field_name}.invalid",
        attribute: attribute,
        default: I18n.t("activerecord.errors.models.edition.invalid", attribute: attribute),
      )
    end
  end

  def strip_multiparameter_keys
    @object_params.to_h.reject { |key, _| key.to_s.match?(/\(\d+i\)$/) }
  end

  def validate_end_after_start(start_converter, end_converter)
    return if end_converter.date_time > start_converter.date_time

    @edition.errors.add(
      "details_date_range_end",
      I18n.t(
        "activerecord.errors.models.edition.minimum",
        attribute: "End",
        minimum_date: "Start",
      ),
    )
  end
end
