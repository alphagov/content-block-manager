module Document::HideableFromSearchIndex
  extend ActiveSupport::Concern

  included do
    before_create :set_testing_artefact
  end

private

  def set_testing_artefact
    self.testing_artefact = current_user_is_e2e_user?
  end

  def current_user_is_e2e_user?
    Current.user&.is_e2e_user? || false
  end
end
