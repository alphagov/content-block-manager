class Shared::DocumentFullStatusComponent < ViewComponent::Base
  include EditionHelper

  def initialize(document:)
    @document = document
    @edition = document.most_recent_edition
  end
end
