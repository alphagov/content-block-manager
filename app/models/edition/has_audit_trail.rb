module Edition::HasAuditTrail
  extend ActiveSupport::Concern

  def self.acting_as(actor)
    original_actor = Current.user
    Current.user = actor
    yield
  ensure
    Current.user = original_actor
  end

  included do
    include Edition::Diffable

    has_many :versions, -> { order(created_at: :desc, id: :desc) }, as: :item

    after_create :record_create
  end

private

  def record_create
    user = Current.user
    versions.create!(event: "created", user:)
  end
end
