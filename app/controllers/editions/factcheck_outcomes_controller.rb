class Editions::FactcheckOutcomesController < BaseController
  def new
    @edition = Edition.find(params[:id])
    @title = block_will_be_scheduled? ? "Schedule block" : "Publish block"
    render :new
  end

  def create
    @edition = Edition.find(params[:id])
    return form_validation_error unless factcheck_outcome_supplied?

    record_factcheck_outcome
  end

private

  def form_validation_error
    alert = "Indicate whether the Factcheck process has been performed or not"
    redirect_to new_factcheck_outcome_path(@edition), alert:
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
end
