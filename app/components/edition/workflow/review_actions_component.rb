class Edition::Workflow::ReviewActionsComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  delegate :pre_release_features?, to: :helpers
end
