module V2
  class Version < ApplicationRecord
    enum :event, { created: 0, updated: 1 }

    belongs_to :item, polymorphic: true
    belongs_to :user, class_name: "User", foreign_key: "whodunnit", optional: true
    has_many :domain_events, class_name: "V2::DomainEvent", foreign_key: :v2_version_id

    validates :event, presence: true

    def self.increment_for_edition(edition:, user:, state:, field_diffs:)
      create!(
        event: "updated",
        item: edition,
        user: user,
        state: state,
        field_diffs: field_diffs,
      )
    end

    def field_diffs
      self[:field_diffs] ? DiffItem.from_hash(self[:field_diffs]) : {}
    end
  end
end
