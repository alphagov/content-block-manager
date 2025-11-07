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
    else
      raise UnhandledSaveActionError, "Unknown save action: '#{@save_action}'"
    end
  end

private

  def publish
    new_edition = PublishEditionService.new.call(@edition)
    workflow_path(id: new_edition.id, step: :confirmation)
  end

  def schedule
    schema = Schema.find_by_block_type(@edition.document.block_type)
    ScheduleEditionService.new(schema).call(@edition)
    workflow_path(id: @edition.id, step: :confirmation, is_scheduled: true)
  end
end

