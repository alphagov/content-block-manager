class Edition::StateTransitionMessage
  def initialize(edition:, state:)
    @edition = edition
    @state = state
  end

  def to_s
    I18n.t("edition.states.transition_message.#{first_or_further}.#{state}")
  end

private

  attr_reader :edition, :state

  def first_or_further
    return "first" if edition.first_edition?

    "further"
  end
end
