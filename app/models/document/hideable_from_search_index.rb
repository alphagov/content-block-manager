module Document::HideableFromSearchIndex
  extend ActiveSupport::Concern

  included do
    before_create :set_testing_artefact
  end

  class_methods do
    def visible_in_search_index
      Current.user&.is_e2e_user? ? all : where(testing_artefact: false)
    end
  end

  def hidden_from_search_index?
    testing_artefact? && !current_user_is_e2e_user?
  end

private

  def set_testing_artefact
    self.testing_artefact = current_user_is_e2e_user?
  end

  def current_user_is_e2e_user?
    Current.user&.is_e2e_user? || false
  end
end
