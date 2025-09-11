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
    @title
  end
  helper_method :context

private

  def review_url
    workflow_path(
      @edition,
      step: :review,
    )
  end
end
