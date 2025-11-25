class Edition::Show::ActionsComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
    @state = edition.state
    @document = edition.document
  end

  attr_reader :edition, :state, :document
end
