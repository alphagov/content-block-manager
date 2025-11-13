class Shared::TransitionButtonComponent < ViewComponent::Base
  class UnknownTransitionError < RuntimeError; end

  def initialize(edition:, transition:)
    @edition = edition
    @transition = raise_if_transition_unknown(transition)
  end

  attr_reader :edition, :transition

  def call_to_action
    "Send to 2i"
  end

private

  def raise_if_transition_unknown(transition)
    return transition if transition.to_sym == :ready_for_2i

    raise(UnknownTransitionError, "Transition event '#{transition}' is not recognised'")
  end
end
