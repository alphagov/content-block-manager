class Edition::WorkflowCompletion
  include Rails.application.routes.url_helpers

  class UnhandledSaveActionError < StandardError; end

  def initialize(edition, save_action)
    @edition = edition
    @save_action = save_action
  end

  def call
    case @save_action
    when "publish"
      publish
    when "schedule"
      schedule
    when "save_as_draft"
      save_as_draft
    else
      raise UnhandledSaveActionError, "Unknown save action: '#{@save_action}'"
    end
  end

private

  def publish
    new_edition = if @edition.state != "published"
                    PublishEditionService.new.call(@edition)
                  else
                    @edition
                  end
    workflow_path(id: new_edition.id, step: :confirmation)
  end

  def schedule
    ScheduleEditionService.new.call(@edition)
    workflow_path(id: @edition.id, step: :confirmation, is_scheduled: true)
  end

  def save_as_draft
    # No action needed here as we don't publish drafts to the Publishing API. Just redirect.
    document_path(@edition.document)
  end
end
