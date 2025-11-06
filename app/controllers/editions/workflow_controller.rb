class Editions::WorkflowController < BaseController
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

  def form_data_attributes
    helpers.ga4_data_attributes(edition: @edition, section: current_step&.show_action)
  end
  helper_method :form_data_attributes

private

  def review_url
    workflow_path(
      @edition,
      step: :review,
    )
  end
end
