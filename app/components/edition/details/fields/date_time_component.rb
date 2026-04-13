class Edition::Details::Fields::DateTimeComponent < ViewComponent::Base
  MULTIPARAMETER_INDEX = { year: 1, month: 2, day: 3, hour: 4, minute: 5 }.freeze

  def initialize(context)
    @context = context
    @block_type = context.field.schema.id.to_s
    @field_name = context.field.name
    @name_prefix = "edition[details][#{@block_type}]"
    @details = context.edition&.details&.dig(block_type, field_name) || {}
    @date_time = DateTimeConverter.from_strings(date: @details["date"], time: @details["time"]).date_time
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
end
