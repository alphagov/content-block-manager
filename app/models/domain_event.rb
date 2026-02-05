class DomainEvent < ApplicationRecord
  belongs_to :document
  belongs_to :user
  belongs_to :edition, optional: true
  belongs_to :version, optional: true

  EVENT_NAMES = %w[
    edition.state_transition.succeeded
  ].freeze

  validates :name, presence: true
  validate :ensure_name_valid

  def ensure_name_valid
    return if name.in? EVENT_NAMES

    errors.add :name, "not known"
  end
end
