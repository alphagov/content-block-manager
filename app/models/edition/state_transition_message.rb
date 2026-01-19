class Edition::StateTransitionMessage
  def initialize(edition:, state:)
    @edition = edition
    @state = state
  end

  def to_s
    if edition.first_edition?
      I18n.t("edition.states.transition_message.first.#{state}")
    else
      I18n.t("edition.states.transition_message.further.#{state}")
    end
  end

private

  attr_reader :edition, :state
end
