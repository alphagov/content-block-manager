module Workflow::UpdateMethods
  extend ActiveSupport::Concern

  REVIEW_ERROR = Data.define(:attribute, :full_message)

  def update_draft
    @edition = Edition.find(params[:id])

    @edition.assign_attributes(
      title: edition_params[:title],
      lead_organisation_id: edition_params[:lead_organisation_id],
      instructions_to_publishers: edition_params[:instructions_to_publishers],
      details: @edition.details.merge(edition_params[:details]),
    )
    @edition.save!

    redirect_to_next_step
  rescue ActiveRecord::RecordInvalid
    @schema = Schema.find_by_block_type(@edition.document.block_type)
    @form = EditionForm::Edit.new(edition: @edition, schema: @schema)

    render :edit_draft, status: :unprocessable_content
  end

  def validate_schedule
    @edition = Edition.find(params[:id])

    validate_scheduled_edition

    redirect_to_next_step
  rescue ActiveRecord::RecordInvalid
    render "editions/workflow/schedule_publishing", status: :unprocessable_content
  end

  def update_internal_note
    @edition.update!(internal_change_note: edition_params[:internal_change_note])

    redirect_to_next_step
  end

  def update_change_note
    @edition.assign_attributes(change_note: edition_params[:change_note], major_change: edition_params[:major_change])
    @edition.save!(context: :change_note)

    redirect_to_next_step
  rescue ActiveRecord::RecordInvalid
    render :change_note, status: :unprocessable_content
  end

  def complete_workflow
    if params[:has_checked_content].blank?
      @check_content_error_copy = I18n.t("edition.review_page.errors.confirm")
      @error_summary_errors = [{ text: @check_content_error_copy, href: "#has_checked_content-0" }]
      render :review, status: :unprocessable_content
    else
      action = Edition::WorkflowCompletion.new(@edition, params[:save_action]).call
      redirect_to action[:path], flash: action[:flash]
    end
  end

private

  def redirect_to_next_step
    redirect_to workflow_path(
      id: @edition.id,
      step: next_step&.name,
    )
  end
end
