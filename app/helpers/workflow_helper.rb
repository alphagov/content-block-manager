module WorkflowHelper
  def button_text_submit_for(edition)
    return "Schedule" if is_scheduling?

    edition.document.is_new_block? ? "Create" : "Publish"
  end
end
