class Shared::DeleteDraftComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition

  def redirect_path
    edition.document.is_new_block? ? root_path : document_path(edition.document)
  end
end
