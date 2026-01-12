class Editions::FactcheckOutcomesController < BaseController
  before_action :set_edition_and_title, only: %i[new identify_performer]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless factcheck_outcome_supplied?

    record_factcheck_outcome

    return finalise_edition if factcheck_skipped?

    redirect_to identify_performer_factcheck_outcome_edition_path(@edition)
  end

  def identify_performer
    render :identify_performer
  end

  def update
    @edition = Edition.find(params[:id])

    begin
      update_factcheck_performer
    rescue ActionController::ParameterMissing
      return handle_missing_factcheck_performer
    end

    finalise_edition
  end

private

  def set_edition_and_title
    @edition = Edition.find(params[:id])
    @title = block_will_be_scheduled? ? "Schedule block" : "Publish block"
  end

  def finalise_edition
    transition_to_next_state
    redirect_to(document_path(@edition.document))
  rescue Transitions::InvalidTransition => e
    handle_other_transition_error(e)
  end

  def update_factcheck_performer
    @edition.factcheck_outcome.update!(
      "performer" => factcheck_performer,
    )
  end

  def factcheck_performer
    if outcome_params["factcheck_performer"].blank?
      raise ActionController::ParameterMissing, I18n.t("edition.outcomes.errors.factcheck.missing_performer")
    end

    outcome_params["factcheck_performer"]
  end

  def form_validation_error
    alert = "Indicate whether the Factcheck process has been performed or not"
    redirect_to new_factcheck_outcome_edition_path(@edition), alert:
  end

  def record_factcheck_outcome
    @edition.create_factcheck_outcome!(
      "skipped" => factcheck_skipped?,
      "creator" => Current.user,
    )
  end

  def factcheck_outcome_supplied?
    outcome_params["factcheck_performed"].present?
  rescue ActionController::ParameterMissing
    false
  end

  def factcheck_skipped?
    ActiveModel::Type::Boolean.new.cast(
      outcome_params["factcheck_performed"],
    ) == false
  end

  def outcome_params
    params.require("factcheck_outcome")
  end

  def block_will_be_scheduled?
    @edition.is_scheduling?
  end

  def transition_to_next_state
    if block_will_be_scheduled?
      @edition.schedule!
      destination_state = "scheduled"
    else
      @edition.publish!
      destination_state = "published"
    end

    flash.notice = I18n.t("edition.states.transition_message.#{destination_state}")
  end

  def handle_other_transition_error(error)
    flash.alert = "Error: we can not change the status of this edition. #{error.message}"
    redirect_to document_path(@edition.document)
  end

  def handle_missing_factcheck_performer(error)
    flash.alert = error.message.to_s
    redirect_to identify_performer_factcheck_outcome_edition_path(@edition)
  end
end
