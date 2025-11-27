class Editions::ReviewOutcomesController < BaseController
  def new
    @edition = Edition.find(params[:id])
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    if review_outcome_supplied?
      record_review_outcome
      begin
        transition_to_awaiting_factcheck_state
        redirect_to(document_path(@edition.document))
      rescue Edition::Workflow::ReviewOutcomeMissingError => e
        flash.alert = e.message
        redirect_to new_review_outcome_path(@edition)
      end
    else
      render :new
    end
  end

private

  def record_review_outcome
    @edition.update(
      "review_skipped" => review_skipped?,
      "review_outcome_recorded_at" => Time.current,
      "review_outcome_recorded_by" => Current.user.id,
    )
  end

  def transition_to_awaiting_factcheck_state
    @edition.ready_for_factcheck!
    state_label = I18n.t("edition.states.label.awaiting_factcheck")
    flash.notice = "Edition has been moved into state '#{state_label}'"
  end

  def review_outcome_supplied?
    outcome_params["review_performed"].present?
  end

  def review_skipped?
    ActiveModel::Type::Boolean.new.cast(
      outcome_params["review_performed"],
    ) == false
  end

  def outcome_params
    params.require("review_outcome")
  end
end
