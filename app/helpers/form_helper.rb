module FormHelper
  def ga4_data_attributes(edition:, section:, block_type: nil)
    {
      data: {
        module: "ga4-form-tracker",
        ga4_form: {
          type: "Content Block",
          tool_name: edition&.document&.block_type || block_type,
          event_name: event_name_for_edition(edition),
          section: section,
        },
      },
    }
  end

  def event_name_for_edition(edition)
    return "create" if edition&.document.nil? || edition&.document&.is_new_block?

    "update"
  end
end
