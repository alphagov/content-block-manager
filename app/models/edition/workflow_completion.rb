class Edition::WorkflowCompletion
  include Rails.application.routes.url_helpers

  VALID_SAVE_ACTIONS = {
    "publish" => :publish,
    "schedule" => :schedule,
    "save_as_draft" => :save_as_draft,
    "send_to_review" => :send_to_review,
  }.freeze

  class UnhandledSaveActionError < StandardError; end

  def initialize(edition, save_action)
    @edition = edition
    @save_action = save_action
  end

  def call
    validate_action
    @edition.complete_draft! if @edition.draft?

    send(sanitised_save_action)
  end

private

  def validate_action
    return true if @save_action.in?(VALID_SAVE_ACTIONS.keys)

    raise UnhandledSaveActionError, "Unknown save action: '#{@save_action}'"
  end

  def sanitised_save_action
    VALID_SAVE_ACTIONS.fetch(@save_action)
  end

  def publish
    new_edition = if @edition.state != "published"
                    PublishEditionService.new.call(@edition)
                  else
                    @edition
                  end
    { path: workflow_path(id: new_edition.id, step: :confirmation) }
  end

  def schedule
    ScheduleEditionService.new.call(@edition)
    { path: workflow_path(id: @edition.id, step: :confirmation, is_scheduled: true) }
  end

  def save_as_draft
    { path: document_path(@edition.document),
      flash: { notice: Edition::StateTransitionMessage.new(
        edition: @edition,
        state: :draft_complete,
      ).to_s } }
  end

  def send_to_review
    @edition.ready_for_review!

    { path: document_path(@edition.document),
      flash: { notice: Edition::StateTransitionMessage.new(
        edition: @edition,
        state: :awaiting_review,
      ).to_s } }
  rescue Transitions::InvalidTransition => e
    record_error(e)

    { path: document_path(@edition.document),
      flash: { error: I18n.t("edition.states.transition_error") } }
  end

  def record_error(error)
    GovukError.notify(
      error.message,
      extra: { edition_id: @edition.id, document_id: @edition.document.id },
    )
  end
end
