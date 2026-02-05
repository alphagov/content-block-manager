class Version < ApplicationRecord
  enum :event, { created: 0, updated: 1 }

  belongs_to :item, polymorphic: true
  validates :event, presence: true
  belongs_to :user, foreign_key: "whodunnit", optional: true
  has_many :domain_events

  def field_diffs
    self[:field_diffs] ? DiffItem.from_hash(self[:field_diffs]) : {}
  end
end
