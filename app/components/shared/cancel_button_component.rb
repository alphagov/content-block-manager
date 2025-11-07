class Shared::CancelButtonComponent < ViewComponent::Base
  def initialize(edition)
    @edition = edition
  end

private

  attr_reader :edition

  def is_editing?
    edition.document.editions.count > 1
  end
end
