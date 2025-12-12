class Editions::FactcheckOutcomesController < BaseController
  before_action :set_instance_vars, only: %i[new review]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless factcheck_outcome_supplied?

    record_factcheck_outcome

    if factcheck_skipped?
      finalise_edition
      return
    end

    redirect_to review_factcheck_outcome_edition_path(@edition)
  end

  def review
    render :review
  end

  def update
    @edition = Edition.find(params[:id])

    begin
      update_factcheck_reviewer
    rescue ActionController::ParameterMissing => e
      return handle_missing_factcheck_reviewer(e)
    end

    finalise_edition
  end

private

  def set_instance_vars
    @edition = Edition.find(params[:id])
    @title = block_will_be_scheduled? ? "Schedule block" : "Publish block"
  end

  def finalise_edition
    transition_to_next_state
    redirect_to(document_path(@edition.document))
  rescue Transitions::InvalidTransition => e
    handle_other_transition_error(e)
  end

  def update_factcheck_reviewer
    @edition.update(
      "factcheck_outcome_reviewer" => factcheck_reviewer,
    )
  end

  def factcheck_reviewer
    if outcome_params["factcheck_reviewer"].blank?
      raise ActionController::ParameterMissing, "Factcheck reviewer is required when factcheck is performed"
    end

    outcome_params["factcheck_reviewer"]
  end

  def form_validation_error
    alert = "Indicate whether the Factcheck process has been performed or not"
    redirect_to new_factcheck_outcome_edition_path(@edition), alert:
  end

  def record_factcheck_outcome
    @edition.update(
      "factcheck_skipped" => factcheck_skipped?,
      "factcheck_outcome_recorded_at" => Time.current,
      "factcheck_outcome_recorded_by" => Current.user.id,
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
      state_label = I18n.t("edition.states.label.scheduled")
    else
      @edition.publish!
      state_label = I18n.t("edition.states.label.published")
    end

    flash.notice = "Edition has been moved into state '#{state_label}'"
  end

  def handle_other_transition_error(error)
    flash.alert = "Error: we can not change the status of this edition. #{error.message}"
    redirect_to document_path(@edition.document)
  end

  def handle_missing_factcheck_reviewer(error)
    flash.alert = error.message.to_s
    redirect_to review_factcheck_outcome_edition_path(@edition)
  end
end
