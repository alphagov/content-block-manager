class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  MULTIPARAMETER_INDEX = { year: 1, month: 2, day: 3, hour: 4, minute: 5 }.freeze

  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @date_time = parse_datetime_from_details
  end

  attr_reader :context, :field_name, :name_prefix, :block_type, :date_time

  def id_for(field)
    "#{field_name}_#{field}"
  end

  def name_for(field)
    index = MULTIPARAMETER_INDEX.fetch(field)
    "#{name_prefix}[#{field_name}(#{index}i)]"
  end

  def label_for(field)
    I18n.t("date_time.field_labels.#{field}")
  end

private

  def parse_datetime_from_details
    return raw_submitted_datetime if re_rendering_due_to_validation_failure?

    value = context.edition&.details&.dig(block_type, field_name)
    return nil if value.blank?

    case value
    when String
      Time.zone.parse(value)
    when Hash
      DateAndTime::Converter.from_strings(date: value["date"], time: value["time"]).date_time
    end
  end

  def re_rendering_due_to_validation_failure?
    context.details.present? && context.details["#{field_name}(1i)"].present?
  end

  def raw_submitted_datetime
    DateAndTime::RawValues.from_params(context.details, field_name)
  end
end
