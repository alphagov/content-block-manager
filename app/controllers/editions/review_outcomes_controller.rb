class Editions::ReviewOutcomesController < BaseController
  before_action :set_edition_and_title, only: %i[new identify_performer update]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless review_outcome_supplied?

    record_review_outcome

    return transition_edition_and_redirect if review_skipped?

    redirect_to identify_performer_review_outcome_edition_path(@edition)
  end

  def identify_performer
    render :identify_performer
  end

  def update
    begin
      update_review_performer
    rescue ActionController::ParameterMissing
      return handle_missing_review_performer
    end

    transition_edition_and_redirect
  end

private

  def set_edition_and_title
    @edition = Edition.find(params[:id])
    @title = "Send to Factcheck"
  end

  def transition_edition_and_redirect
    transition_to_awaiting_factcheck_state
    redirect_to(document_path(@edition.document))
  rescue Transitions::InvalidTransition => e
    handle_other_transition_error(e)
  end

  def update_review_performer
    @edition.review_outcome.update!(
      "performer" => review_performer,
    )
  end

  def review_performer
    if outcome_params["review_performer"].blank?
      raise ActionController::ParameterMissing, I18n.t("edition.outcomes.errors.factcheck.missing_performer")
    end

    outcome_params["review_performer"]
  end

  def form_validation_error
    flash.now.alert = I18n.t("edition.outcomes.errors.review.missing_outcome")
    render :new
  end

  def record_review_outcome
    @edition.create_review_outcome!(
      "skipped" => review_skipped?,
      "creator" => Current.user,
    )
  end

  def transition_to_awaiting_factcheck_state
    @edition.ready_for_factcheck!
    flash.notice = I18n.t("edition.states.transition_message.awaiting_factcheck")
  end

  def review_outcome_supplied?
    outcome_params["review_performed"].present?
  rescue ActionController::ParameterMissing
    false
  end

  def review_skipped?
    ActiveModel::Type::Boolean.new.cast(
      outcome_params["review_performed"],
    ) == false
  end

  def outcome_params
    params.require("review_outcome")
  end

  def handle_missing_review_performer
    flash.alert = I18n.t("edition.outcomes.errors.review.missing_performer")
    redirect_to identify_performer_review_outcome_edition_path(@edition)
  end

  def handle_other_transition_error(error)
    flash.alert = "Error: we can not change the status of this edition. #{error.message}"
    redirect_to document_path(@edition.document)
  end
end
