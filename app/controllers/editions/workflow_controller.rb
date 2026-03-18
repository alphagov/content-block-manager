class Editions::WorkflowController < BaseController
  include FormHelper
  include SchedulingValidator

  include Workflow::HasSteps
  include Workflow::ShowMethods
  include Workflow::UpdateMethods

  def show
    send(current_step.show_action)
  rescue UnknownStepError => e
    raise ActionController::RoutingError, e.message
  end

  def cancel
    @edition = Edition.find(params[:id])
  end

  def update
    send(current_step.update_action)
  rescue UnknownStepError => e
    raise ActionController::RoutingError, e.message
  end

  def context
    @edition.title
  end
  helper_method :context

  def page_title(**args)
    step = args.delete(:step) || current_step.name
    I18n.t("edition.workflow.steps.#{step}.title", **args)
  end
  helper_method :page_title

private

  def review_url
    workflow_path(
      @edition,
      step: :review,
    )
  end
end
