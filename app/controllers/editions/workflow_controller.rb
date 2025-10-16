class Editions::WorkflowController < BaseController
  include CanScheduleOrPublish

  include Workflow::Steps
  include Workflow::ShowMethods
  include Workflow::UpdateMethods

  def show
    action = current_step&.show_action

    if action
      send(action)
    else
      raise ActionController::RoutingError, "Step #{params[:step]} does not exist"
    end
  end

  def cancel
    @edition = Edition.find(params[:id])
  end

  def update
    action = current_step&.update_action

    if action
      send(action)
    else
      raise ActionController::RoutingError, "Step #{params[:step]} does not exist"
    end
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
