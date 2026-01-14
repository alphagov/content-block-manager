class Edition::Workflow::ReviewActionsComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  delegate :pre_release_features?, to: :helpers
  delegate :state, to: :@edition

  def button_text
    return "Schedule" if @edition.is_scheduling?

    @edition.document.is_new_block? ? I18n.t("review_actions.create") : I18n.t("review_actions.publish")
  end

  def save_action
    @edition.is_scheduling? ? "schedule" : "publish"
  end
end
