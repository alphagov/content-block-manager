class Editions::StatusTransitionsController < BaseController
  class UnknownTransitionError < RuntimeError; end
  class UnsupportedTransitionError < RuntimeError; end

  def create
    @edition = Edition.find(params[:id])
    begin
      attempt_transition!
      handle_success
    rescue Transitions::InvalidTransition, Edition::Workflow::WorkflowCompletionError => e
      handle_failure(e)
    ensure
      redirect_to redirect_path
    end
  end

private

  def transition
    params.fetch(:transition)
  end

  def attempt_transition!
    raise_if_transition_invalid

    @edition.send("#{transition}!")
  end

  def raise_if_transition_invalid
    raise_transition_unknown_error unless @edition.respond_to?(transition)
    raise_transition_unsupported_error if transition_unsupported?
  end

  def raise_transition_unknown_error
    raise UnknownTransitionError, "Transition event '#{transition}' is not recognised"
  end

  def raise_transition_unsupported_error
    raise UnsupportedTransitionError, "Transition event '#{transition}' is not supported by this controller"
  end

  def transition_unsupported?
    transition.in?(%w[complete_draft schedule])
  end

  def handle_success
    flash[:success] = Edition::StateTransitionMessage.new(
      edition: @edition,
      state: @edition.state,
    ).to_s

    add_important_notice if @edition.awaiting_review? || @edition.awaiting_factcheck?
  end

  def add_important_notice
    flash[:notice] = I18n.t("edition.states.important_notice.#{@edition.state}")
  end

  def handle_failure(error)
    record_error(error)
    flash.alert = I18n.t("edition.states.transition_error")
  end

  def record_error(error)
    GovukError.notify(
      error.message,
      extra: { edition_id: @edition.id, document_id: @edition.document.id },
    )
  end

  def redirect_path
    @edition.document.most_recent_edition ? document_path(@edition.document) : root_path
  end
end
