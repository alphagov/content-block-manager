class Shared::TransitionButtonComponent < ViewComponent::Base
  class UnknownTransitionError < RuntimeError; end

  def initialize(edition:, transition:)
    @edition = edition
    @transition = raise_if_transition_unknown(transition)
  end

  attr_reader :edition, :transition

  def call_to_action
    I18n.t("edition.transitions.#{transition}")
  end

private

  def raise_if_transition_unknown(transition)
    return transition if @edition.available_transitions.include?(transition.to_sym)

    raise(UnknownTransitionError, "Transition event '#{transition}' is not recognised'")
  end
end
