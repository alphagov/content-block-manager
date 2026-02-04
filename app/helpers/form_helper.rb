module FormHelper
  def ga4_data_attributes(edition:, block_type: nil)
    {
      data: {
        module: "ga4-form-tracker",
        ga4_action: event_name_for_edition(edition),
        ga4_tool_name: edition&.document&.block_type || block_type,
      },
    }
  end

  def ga4_form_tracking?
    Flipflop.enabled?("ga4_form_tracking".to_sym)
  end

  def event_name_for_edition(edition)
    return "create" if edition&.document.nil? || edition&.document&.is_new_block?

    "update"
  end

  def value_for_field(details:, field:, populate_with_defaults:)
    default_value = populate_with_defaults ? field.default_value : nil
    details&.dig(field.name) || default_value
  end

  def component_for_field(field, context)
    field.component_class.new(context)
  end
end
