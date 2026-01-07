class Edition::Show::ActionsComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
    @state = edition.state
    @document = edition.document
  end

  attr_reader :edition, :state, :document

  delegate :draft?, to: :edition

  def finalised_state?
    state.to_sym.in?(Edition.finalised_states)
  end

  def has_more_recent_draft?
    document.most_recent_edition&.id != edition.id
  end
end
