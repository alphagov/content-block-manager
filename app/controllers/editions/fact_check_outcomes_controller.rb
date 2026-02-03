class Editions::FactCheckOutcomesController < BaseController
  before_action :set_edition_and_title, only: %i[new identify_performer]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless fact_check_outcome_supplied?

    record_fact_check_outcome

    return finalise_edition if fact_check_skipped?

    redirect_to identify_performer_fact_check_outcome_edition_path(@edition)
  end

  def identify_performer
    @transition = block_will_be_scheduled? ? "schedule" : "publish"

    render :identify_performer
  end

  def update
    @edition = Edition.find(params[:id])

    begin
      update_fact_check_performer
    rescue ActionController::ParameterMissing
      return handle_missing_fact_check_performer
    end

    finalise_edition
  end

private

  def set_edition_and_title
    @edition = Edition.find(params[:id])
    @title = I18n.t("edition.outcomes.heading.fact_check")
  end

  def finalise_edition
    transition_to_next_state
    redirect_to(document_path(@edition.document))
  rescue Transitions::InvalidTransition => e
    handle_other_transition_error(e)
  end

  def update_fact_check_performer
    @edition.fact_check_outcome.update!(
      "performer" => fact_check_performer,
    )
  end

  def fact_check_performer
    if outcome_params["fact_check_performer"].blank?
      raise ActionController::ParameterMissing, I18n.t("edition.outcomes.errors.missing_performer.fact_check")
    end

    outcome_params["fact_check_performer"]
  end

  def form_validation_error
    alert = I18n.t("edition.outcomes.errors.missing_outcome.fact_check")
    redirect_to new_fact_check_outcome_edition_path(@edition), alert:
  end

  def record_fact_check_outcome
    @edition.create_fact_check_outcome!(
      "skipped" => fact_check_skipped?,
      "creator" => Current.user,
    )
  end

  def fact_check_outcome_supplied?
    outcome_params["fact_check_performed"].present?
  rescue ActionController::ParameterMissing
    false
  end

  def fact_check_skipped?
    ActiveModel::Type::Boolean.new.cast(
      outcome_params["fact_check_performed"],
    ) == false
  end

  def outcome_params
    params.require("fact_check_outcome")
  end

  def block_will_be_scheduled?
    @edition.is_scheduling?
  end

  def transition_to_next_state
    if block_will_be_scheduled?
      ScheduleEditionService.new.call(@edition)
      destination_state = "scheduled"
    else
      PublishEditionService.new.call(@edition)
      destination_state = "published"
    end

    flash[:success] = Edition::StateTransitionMessage.new(
      edition: @edition,
      state: destination_state,
    ).to_s
  end

  def handle_other_transition_error(error)
    record_error(error)
    flash.alert = I18n.t("edition.states.transition_error")
    redirect_to document_path(@edition.document)
  end

  def handle_missing_fact_check_performer
    flash.alert = I18n.t("edition.outcomes.errors.missing_performer.fact_check")
    redirect_to identify_performer_fact_check_outcome_edition_path(@edition)
  end

  def record_error(error)
    Edition::StateTransitionErrorReport.new(
      error: error,
      edition: @edition,
    ).call
  end
end
