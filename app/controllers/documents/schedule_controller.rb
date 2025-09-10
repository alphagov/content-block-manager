class Documents::ScheduleController < BaseController
  include CanScheduleOrPublish

  def edit
    document = Document.find(params[:document_id])
    @edition = document.latest_edition
  end

  def update
    document = Document.find(params[:document_id])
    @edition = document.latest_edition.clone_edition(creator: current_user)

    validate_scheduled_edition

    redirect_to workflow_path(@edition, step: :review)
  rescue ActiveRecord::RecordInvalid
    render "documents/schedule/edit"
  end
end
