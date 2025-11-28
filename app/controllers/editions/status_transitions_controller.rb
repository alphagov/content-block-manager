class Editions::StatusTransitionsController < BaseController
  class UnknownTransitionError < RuntimeError; end

  def create
    @edition = Edition.find(params[:id])
    begin
      attempt_transition!(transition: params.fetch(:transition))
      handle_success
    rescue Transitions::InvalidTransition => e
      handle_failure(e)
    ensure
      redirect_to document_path(@edition.document)
    end
  end

private

  def attempt_transition!(transition:)
    transition_method = "#{transition}!"
    if @edition.respond_to?(transition_method)
      @edition.send(transition_method)
    else
      raise UnknownTransitionError, "Transition event '#{transition}' is not recognised"
    end
  end

  def handle_success
    flash.notice = "Edition has been moved into state '#{@edition.state}'"
  end

  def handle_failure(error)
    flash.alert = "Error: we can not change the status of this edition. #{error.message}"
  end
end
