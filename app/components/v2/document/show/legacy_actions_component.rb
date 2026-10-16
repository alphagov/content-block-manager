class V2::Document::Show::LegacyActionsComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    @edition = document.most_recent_edition
    @state = edition.state
  end

  attr_reader :edition, :state, :document

  delegate :draft?, to: :edition

  def finalised_state?
    state.to_sym.in?(V2::Edition.finalised_states)
  end
end
