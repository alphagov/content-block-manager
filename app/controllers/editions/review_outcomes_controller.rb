class Editions::ReviewOutcomesController < BaseController
  before_action :set_edition_and_title, only: %i[new]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless review_outcome_supplied?

    @edition.create_review_outcome!({
      "skipped" => review_skipped?,
      "creator" => Current.user,
      "performer" => review_performer,
    }.compact)

    transition_edition_and_redirect
  end

private

  def set_edition_and_title
    @edition = Edition.find(params[:id])
    @title = I18n.t("edition.outcomes.heading.review")
  end

  def transition_edition_and_redirect
    transition_to_awaiting_factcheck_state
    redirect_to(document_path(@edition.document))
  rescue Transitions::InvalidTransition => e
    handle_other_transition_error(e)
  end

  def review_performer
    outcome_params["review_performer"].presence
  end

  def form_validation_error
    flash.now.alert = I18n.t("edition.outcomes.errors.missing_outcome.review")
    render :new
  end

  def transition_to_awaiting_factcheck_state
    @edition.ready_for_factcheck!

    flash[:success] = Edition::StateTransitionMessage.new(
      edition: @edition,
      state: :awaiting_factcheck,
    ).to_s

    flash[:notice] = I18n.t("edition.states.important_notice.awaiting_factcheck")
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

  def handle_other_transition_error(error)
    record_error(error)
    flash.alert = I18n.t("edition.states.transition_error")
    redirect_to document_path(@edition.document)
  end

  def record_error(error)
    Edition::StateTransitionErrorReport.new(
      error: error,
      edition: @edition,
    ).call
  end
end
