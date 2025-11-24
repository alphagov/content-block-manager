class Shared::DocumentFullStatusComponent < ViewComponent::Base
  include EditionHelper

  def initialize(edition:)
    @edition = edition
  end
end
