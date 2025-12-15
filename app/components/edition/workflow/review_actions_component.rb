class Edition::Workflow::ReviewActionsComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  delegate :pre_release_features?, to: :helpers

  def button_text
    return "Schedule" if @edition.is_scheduling?

    @edition.document.is_new_block? ? "Create" : "Publish"
  end

  def save_action
    @edition.is_scheduling? ? "schedule" : "publish"
  end
end
