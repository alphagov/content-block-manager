class Edition::StateTransitionMessage
  def initialize(state:)
    @state = state
  end

  def to_s
    I18n.t("edition.states.transition_message.#{state}")
  end

private

  attr_reader :state
end
