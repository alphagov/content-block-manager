class Editions::ReviewOutcomesController < BaseController
  before_action :set_edition_and_title, only: %i[new identify_performer]

  def new
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless review_outcome_supplied?

    record_review_outcome

    redirect_to identify_performer_review_outcome_edition_path(@edition)
  end

  def identify_performer
    render :identify_performer
  end
    begin
      transition_to_awaiting_factcheck_state
      redirect_to(document_path(@edition.document))
    rescue Edition::Workflow::ReviewOutcomeMissingError => e
      handle_missing_review_outcome(e)
    rescue Transitions::InvalidTransition => e
      handle_other_transition_error(e)
    end
  end

private

  def set_edition_and_title
    @edition = Edition.find(params[:id])
    @title = "Send to Factcheck"
  end
  def form_validation_error
    flash.now.alert = "Indicate whether the 2i Review process has been performed or not"
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

  def handle_missing_review_outcome(error)
    flash.alert = error.message
    redirect_to new_review_outcome_path(@edition)
  end

  def handle_other_transition_error(error)
    flash.alert = "Error: we can not change the status of this edition. #{error.message}"
    redirect_to document_path(@edition.document)
  end
end
